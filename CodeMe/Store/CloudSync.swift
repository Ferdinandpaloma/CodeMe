import Foundation
import Observation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Backs up the learner's progress to Firestore at `users/{uid}` and keeps devices in step.
///
/// - Signs in anonymously so every install gets a private account with no sign-up step.
/// - The first time an account is linked on a device, local and cloud progress are merged
///   so nothing is lost. After that, the newest write wins and is applied in real time.
/// - UserDefaults stays the local source, so the app works fully offline; Firestore's own
///   offline cache queues writes until the network returns.
/// - If GoogleService-Info.plist is missing or belongs to another bundle ID, sync stays off.
@MainActor
@Observable
final class CloudSync {
    enum Status: Equatable {
        case disabled(String)
        case connecting
        case syncing
        case synced(Date)
        case failed(String)
    }

    private(set) var status: Status = .connecting
    private(set) var userID: String?

    @ObservationIgnored private weak var store: ProgressStore?
    @ObservationIgnored private var listener: ListenerRegistration?
    @ObservationIgnored private var authHandle: AuthStateDidChangeListenerHandle?
    @ObservationIgnored private var pushTask: Task<Void, Never>?
    @ObservationIgnored private var lastAppliedRemote: Date = .distantPast
    @ObservationIgnored private let defaults = UserDefaults.standard

    private static let deviceKey = "cloud.deviceID"
    private static let mergedUIDKey = "cloud.mergedUID"

    /// Stable per-install ID so a device ignores its own writes coming back.
    private let deviceID: String = {
        if let id = UserDefaults.standard.string(forKey: deviceKey) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: deviceKey)
        return id
    }()

    private struct Document: Codable {
        var progress: ProgressSnapshot
        var updatedAt: Date
        var deviceID: String
        var schema = 1
    }

    // MARK: Setup

    /// Configures Firebase if a matching GoogleService-Info.plist is bundled.
    /// Returns a reason string when sync can't be enabled.
    static func configure() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            return "Add GoogleService-Info.plist to enable cloud sync."
        }
        let plistBundle = options.bundleID
        if plistBundle != Bundle.main.bundleIdentifier {
            return "GoogleService-Info.plist is for \(plistBundle), not \(Bundle.main.bundleIdentifier ?? "this app")."
        }
        if FirebaseApp.app() == nil { FirebaseApp.configure(options: options) }
        return nil
    }

    init(disabledReason: String?) {
        if let disabledReason { status = .disabled(disabledReason) }
    }

    var isEnabled: Bool {
        if case .disabled = status { return false }
        return true
    }

    func start(with store: ProgressStore) {
        guard isEnabled, self.store == nil else { return }
        self.store = store
        store.onChange = { [weak self] in self?.schedulePush() }

        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.userChanged(user) }
        }
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { [weak self] _, error in
                if let error {
                    Task { @MainActor in self?.status = .failed(Self.describe(error)) }
                }
            }
        }
    }

    // MARK: Account

    private func userChanged(_ user: User?) {
        listener?.remove()
        listener = nil
        userID = user?.uid
        guard let uid = user?.uid else {
            if isEnabled { status = .connecting }
            return
        }
        status = .syncing
        Task { await initialSync(uid: uid) }
    }

    private func reference(_ uid: String) -> DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }

    private func initialSync(uid: String) async {
        guard let store else { return }
        do {
            let snapshot = try await reference(uid).getDocument()
            let remote = snapshot.exists ? try snapshot.data(as: Document.self) : nil
            let local = store.snapshot
            let firstLinkOnDevice = defaults.string(forKey: Self.mergedUIDKey) != uid

            if let remote {
                // First time on this device: merge so neither side loses work.
                // Afterwards the cloud copy is authoritative when we (re)connect.
                let result = firstLinkOnDevice ? local.merged(with: remote.progress) : remote.progress
                lastAppliedRemote = remote.updatedAt
                store.apply(result)
                if result != remote.progress { try await push(uid: uid, progress: result) }
            } else {
                try await push(uid: uid, progress: local)
            }
            defaults.set(uid, forKey: Self.mergedUIDKey)
            status = .synced(Date())
            listen(uid: uid)
        } catch {
            status = .failed(Self.describe(error))
        }
    }

    // MARK: Pull

    private func listen(uid: String) {
        listener = reference(uid).addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    self.status = .failed(Self.describe(error))
                    return
                }
                guard let snapshot, snapshot.exists, !snapshot.metadata.hasPendingWrites,
                      let remote = try? snapshot.data(as: Document.self),
                      remote.deviceID != self.deviceID,
                      remote.updatedAt > self.lastAppliedRemote else { return }
                self.lastAppliedRemote = remote.updatedAt
                self.store?.apply(remote.progress)
                self.status = .synced(Date())
            }
        }
    }

    // MARK: Push

    /// Debounces bursts of edits (typing code, toggling several problems) into one write.
    private func schedulePush() {
        guard let uid = userID else { return }
        pushTask?.cancel()
        pushTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled, let self, let store = self.store else { return }
            self.status = .syncing
            do {
                try await self.push(uid: uid, progress: store.snapshot)
                self.status = .synced(Date())
            } catch {
                self.status = .failed(Self.describe(error))
            }
        }
    }

    private func push(uid: String, progress: ProgressSnapshot) async throws {
        let now = Date()
        lastAppliedRemote = max(lastAppliedRemote, now)
        let document = Document(progress: progress, updatedAt: now, deviceID: deviceID)
        try reference(uid).setData(from: document)
    }

    func syncNow() {
        guard let uid = userID else { return }
        status = .syncing
        listener?.remove()
        listener = nil
        Task { await initialSync(uid: uid) }
    }

    private static func describe(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == FirestoreErrorDomain, nsError.code == FirestoreErrorCode.permissionDenied.rawValue {
            return "Permission denied. Check the Firestore security rules."
        }
        if nsError.domain == AuthErrorDomain, nsError.code == AuthErrorCode.operationNotAllowed.rawValue {
            return "Enable Anonymous sign-in in the Firebase console."
        }
        return error.localizedDescription
    }
}
