import SwiftUI

struct ProblemsListView: View {
    @Environment(ProgressStore.self) private var store
    @State private var search = ""
    @State private var difficulty: Difficulty?
    @State private var status: StatusFilter = .all

    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case todo = "To Do"
        case solved = "Solved"
        case starred = "Starred"
        var id: Self { self }
    }

    private var filtered: [Problem] {
        let query = search.trimmingCharacters(in: .whitespaces)
        return ProblemBank.all.filter { problem in
            if let difficulty, problem.difficulty != difficulty { return false }
            switch status {
            case .all: break
            case .todo: if store.isSolved(problem) { return false }
            case .solved: if !store.isSolved(problem) { return false }
            case .starred: if !store.isStarred(problem) { return false }
            }
            guard !query.isEmpty else { return true }
            return problem.title.localizedCaseInsensitiveContains(query)
                || String(problem.number).hasPrefix(query)
                || problem.topic.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            let results = filtered
            List {
                Section {
                    filterBar
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

                ForEach(Topic.allCases) { topic in
                    let items = results.filter { $0.topic == topic }
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { problem in
                                NavigationLink(value: problem) {
                                    ProblemRow(problem: problem, showTopic: false)
                                }
                                .listRowBackground(Theme.card)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        withAnimation { store.toggleSolved(problem) }
                                    } label: {
                                        Label(store.isSolved(problem) ? "Unsolve" : "Solved", systemImage: "checkmark")
                                    }
                                    .tint(Theme.easy)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        store.toggleStar(problem)
                                    } label: {
                                        Label("Star", systemImage: store.isStarred(problem) ? "star.slash" : "star")
                                    }
                                    .tint(.yellow)
                                }
                            }
                        } header: {
                            Label(topic.name, systemImage: topic.icon)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(topic.color)
                                .textCase(nil)
                        }
                    }
                }

                if results.isEmpty {
                    ContentUnavailableView.search(text: search)
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .searchable(text: $search, prompt: "Title, number, or topic")
            .navigationTitle("Problems")
            .appDestinations()
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Status", selection: $status.animation(.snappy)) {
                ForEach(StatusFilter.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All levels", isOn: difficulty == nil) {
                        withAnimation(.snappy) { difficulty = nil }
                    }
                    ForEach(Difficulty.allCases) { level in
                        FilterChip(title: level.rawValue, isOn: difficulty == level, color: level.color) {
                            withAnimation(.snappy) { difficulty = difficulty == level ? nil : level }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
