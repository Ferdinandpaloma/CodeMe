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
}
