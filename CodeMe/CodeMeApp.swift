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
    var body: some View {
        TabView {
            RoadmapView()
                .tabItem { Label("Roadmap", systemImage: "map.fill") }
            ProblemsListView()
                .tabItem { Label("Problems", systemImage: "list.bullet.rectangle.fill") }
            QuizView()
                .tabItem { Label("Trainer", systemImage: "brain.head.profile") }
            StatsView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
        }
        .tint(Theme.accent)
    }
}

extension View {
    /// Registers navigation destinations shared by every tab's NavigationStack.
    func appDestinations() -> some View {
        self
            .navigationDestination(for: Topic.self) { TopicDetailView(topic: $0) }
            .navigationDestination(for: Problem.self) { ProblemDetailView(problem: $0) }
    }
}
