import SwiftUI

@main
struct CodeMeApp: App {
    @State private var store = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

struct RootView: View {
    @Environment(ProgressStore.self) private var store
    @AppStorage(SettingsKey.appearance) private var appearance = Appearance.system

    var body: some View {
        TabView {
            RoadmapView()
                .tabItem { Label("Roadmap", systemImage: "map.fill") }
            ProblemsListView()
                .tabItem { Label("Problems", systemImage: "list.bullet.rectangle.fill") }
            PracticeView()
                .tabItem { Label("Practice", systemImage: "brain.head.profile") }
                .badge(store.dueReviews.count)
            StatsView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
        }
        .tint(Theme.accent)
        .preferredColorScheme(appearance.colorScheme)
        .achievementToasts()
    }
}

extension View {
    /// Registers navigation destinations shared by every tab's NavigationStack.
    func appDestinations() -> some View {
        self
            .navigationDestination(for: Topic.self) { TopicDetailView(topic: $0) }
            .navigationDestination(for: Problem.self) { ProblemDetailView(problem: $0) }
            .navigationDestination(for: Lesson.self) { LessonView(lesson: $0) }
            .navigationDestination(for: ReferenceSheet.self) { ReferenceView(sheet: $0) }
    }
}
