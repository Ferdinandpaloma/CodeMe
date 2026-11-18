import SwiftUI

/// UserDefaults keys for user preferences (read with @AppStorage).
enum SettingsKey {
    static let appearance = "settings.appearance"
    static let editorFontSize = "settings.editorFontSize"
    static let dailyGoal = "settings.dailyGoal"
    static let autoPair = "settings.autoPair"
    static let lockSolutions = "settings.lockSolutions"
    static let interviewMinutes = "settings.interviewMinutes"

    static let defaultFontSize: Double = 14
    static let defaultDailyGoal = 2
}

enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: Self { self }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct SettingsView: View {
    @Environment(ProgressStore.self) private var store
    @Environment(CloudSync.self) private var sync
    @Environment(\.dismiss) private var dismiss

    @AppStorage(SettingsKey.appearance) private var appearance = Appearance.system
    @AppStorage(SettingsKey.editorFontSize) private var fontSize = SettingsKey.defaultFontSize
    @AppStorage(SettingsKey.dailyGoal) private var dailyGoal = SettingsKey.defaultDailyGoal
    @AppStorage(SettingsKey.autoPair) private var autoPair = true
    @AppStorage(SettingsKey.lockSolutions) private var lockSolutions = true
    @AppStorage(SettingsKey.interviewMinutes) private var interviewMinutes = 45

    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(Appearance.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    Stepper(value: $fontSize, in: 11...20, step: 1) {
                        LabeledContent("Font size", value: "\(Int(fontSize)) pt")
                    }
                    Toggle("Auto-close brackets & quotes", isOn: $autoPair)
                    CodeBlockView(code: "def greet(name: str) -> str:\n    return f\"Hi, {name}!\"  # preview", fileName: "preview.py")
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                } header: {
                    Text("Code editor")
                }

                Section {
                    Stepper(value: $dailyGoal, in: 1...10) {
                        LabeledContent("Daily goal", value: "\(dailyGoal) problem\(dailyGoal == 1 ? "" : "s")")
                    }
                    Toggle("Hide solutions until revealed", isOn: $lockSolutions)
                    Picker("Mock interview length", selection: $interviewMinutes) {
                        ForEach([20, 30, 45, 60], id: \.self) { Text("\($0) min").tag($0) }
                    }
                } header: {
                    Text("Learning")
                } footer: {
                    Text("Hiding solutions encourages you to attempt each problem before reading the answer.")
                }

                Section {
                    LabeledContent("Status") {
                        HStack(spacing: 6) {
                            SwapIcon(syncIcon)
                                .fontWeight(.semibold)
                                .foregroundStyle(syncColor)
                            Text(syncLabel)
                                .contentTransition(.interpolate)
                        }
                        .animation(.snappy, value: sync.status)
                    }
                    if let uid = sync.userID {
                        LabeledContent("Account ID") {
                            Text(uid.prefix(10) + "…")
                                .font(.footnote.monospaced())
                                .textSelection(.enabled)
                        }
                    }
                    if sync.isEnabled {
                        Button("Sync Now") { sync.syncNow() }
                            .disabled(sync.userID == nil || sync.status == .syncing)
                    }
                } header: {
                    Text("Cloud sync")
                } footer: {
                    Text(syncFooter)
                }

                Section {
                    LabeledContent("Problems", value: "\(ProblemBank.all.count)")
                    LabeledContent("Lessons", value: "\(LessonBank.all.count)")
                    LabeledContent("Walkthroughs", value: "\(Walkthroughs.available.count)")
                    LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                } header: {
                    Text("About")
                }

                Section {
                    Button("Reset All Progress", role: .destructive) { confirmReset = true }
                } footer: {
                    Text("Clears solved problems, stars, saved code, notes, reviews, lessons and interview history.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset Everything", role: .destructive) {
                    withAnimation { store.resetAll() }
                }
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }

    private var syncIcon: String {
        switch sync.status {
        case .disabled: "icloud.slash"
        case .connecting, .syncing: "arrow.triangle.2.circlepath.icloud"
        case .synced: "checkmark.icloud"
        case .failed: "exclamationmark.icloud"
        }
    }

    private var syncColor: Color {
        switch sync.status {
        case .disabled: .secondary
        case .connecting, .syncing: Theme.accent
        case .synced: Theme.easy
        case .failed: Theme.hard
        }
    }

    private var syncLabel: String {
        switch sync.status {
        case .disabled: "Off"
        case .connecting: "Connecting…"
        case .syncing: "Syncing…"
        case .synced(let date): "Synced \(date.formatted(date: .omitted, time: .shortened))"
        case .failed: "Error"
        }
    }

    private var syncFooter: String {
        switch sync.status {
        case .disabled(let reason): reason
        case .failed(let message): message
        default: "Progress, code, notes and interview history are backed up to your private account and still work offline."
        }
    }
}
