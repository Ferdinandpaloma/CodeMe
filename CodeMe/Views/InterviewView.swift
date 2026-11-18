import SwiftUI

enum InterviewFormat: String, CaseIterable, Identifiable {
    case screen, onsite, hard

    var id: Self { self }

    var title: String {
        switch self {
        case .screen: "Phone Screen"
        case .onsite: "Onsite Round"
        case .hard: "Final Round"
        }
    }

    var subtitle: String {
        switch self {
        case .screen: "1 Medium"
        case .onsite: "1 Easy + 1 Medium"
        case .hard: "1 Medium + 1 Hard"
        }
    }

    var icon: String {
        switch self {
        case .screen: "phone.fill"
        case .onsite: "building.2.fill"
        case .hard: "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .screen: Theme.easy
        case .onsite: Theme.medium
        case .hard: Theme.hard
        }
    }

    var levels: [Difficulty] {
        switch self {
        case .screen: [.medium]
        case .onsite: [.easy, .medium]
        case .hard: [.medium, .hard]
        }
    }
}

/// Setup screen for a timed mock interview, plus history of past attempts.
struct InterviewSetupView: View {
    @Environment(ProgressStore.self) private var store
    @AppStorage(SettingsKey.interviewMinutes) private var minutes = 45
    @State private var format: InterviewFormat = .onsite
    @State private var session: InterviewSession?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Theme.brandGradient)
                    Text("Simulate the real thing")
                        .font(.title2.weight(.bold))
                    Text("You get random problems you haven't solved yet and a countdown. Talk through your approach out loud, write the code, and only peek at hints if you're stuck, since hints are counted.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                SectionHeader("Format", icon: "list.bullet.rectangle")
                ForEach(InterviewFormat.allCases) { option in
                    Button {
                        withAnimation(.snappy) { format = option }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: option.icon)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(option.color.oklchGradient, in: .rounded(Radius.control))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title).font(.headline).foregroundStyle(.primary)
                                Text(option.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            SwapIcon(format == option ? "checkmark.circle.fill" : "circle")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(format == option ? Theme.accent : Color.secondary.opacity(0.4))
                        }
                        .padding(14)
                        .surface(radius: Radius.outer(padding: 14))
                        .overlay {
                            if format == option {
                                RoundedRectangle(cornerRadius: Radius.outer(padding: 14), style: .continuous)
                                    .strokeBorder(Theme.accent, lineWidth: 2)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .buttonStyle(PressableStyle())
                }

                HStack {
                    Label("Time limit", systemImage: "clock")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Picker("Time limit", selection: $minutes) {
                        ForEach([20, 30, 45, 60], id: \.self) { Text("\($0) min").tag($0) }
                    }
                    .pickerStyle(.menu)
                }
                .card(padding: 12)

                Button {
                    session = InterviewSession(problems: pickProblems(), limit: minutes * 60)
                } label: {
                    Label("Start Interview", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.brandGradient, in: .rounded(Radius.control + 2))
                }
                .buttonStyle(PressableStyle())

                if !store.interviews.isEmpty {
                    SectionHeader("History", icon: "clock.arrow.circlepath")
                        .padding(.top, 6)
                    VStack(spacing: 0) {
                        ForEach(store.interviews.prefix(10)) { record in
                            InterviewHistoryRow(record: record)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                            if record != store.interviews.prefix(10).last { Divider().padding(.leading, 14) }
                        }
                    }
                    .card(padding: 0)
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Mock Interview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(item: $session) { session in
            InterviewSessionView(session: session)
        }
    }

    private func pickProblems() -> [Problem] {
        var picked: [Problem] = []
        for level in format.levels {
            let candidates = ProblemBank.all.filter { $0.difficulty == level && !picked.contains($0) && !picked.map(\.topic).contains($0.topic) }
            let fresh = candidates.filter { !store.isSolved($0) }
            if let choice = (fresh.isEmpty ? candidates : fresh).randomElement() {
                picked.append(choice)
            }
        }
        return picked
    }
}

struct InterviewSession: Identifiable {
    let id = UUID()
    let problems: [Problem]
    let limit: Int
}

private struct InterviewHistoryRow: View {
    let record: InterviewRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.passed ? "checkmark.seal.fill" : "xmark.seal")
                .font(.title3.weight(.semibold))
                .foregroundStyle(record.passed ? Theme.easy : Color.secondary)
            VStack(alignment: .leading, spacing: 3) {
                Text(record.problems.map(\.title).joined(separator: " · "))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(record.date.formatted(date: .abbreviated, time: .shortened)) · \(record.solvedIDs.count)/\(record.problemIDs.count) solved · \(record.hintsUsed) hint\(record.hintsUsed == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text(InterviewClock.format(record.seconds))
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(record.seconds > record.limitSeconds ? Theme.hard : .secondary)
        }
    }
}

enum InterviewClock {
    static func format(_ seconds: Int) -> String {
        let s = abs(seconds)
        return String(format: "%@%d:%02d", seconds < 0 ? "-" : "", s / 60, s % 60)
    }
}

// MARK: - Live session

private struct InterviewSessionView: View {
    let session: InterviewSession
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKey.editorFontSize) private var fontSize = SettingsKey.defaultFontSize
    @AppStorage(SettingsKey.autoPair) private var autoPair = true

    @State private var start = Date()
    @State private var current = 0
    @State private var pane: Pane = .problem
    @State private var code: [String: String] = [:]
    @State private var hintsShown: [String: Int] = [:]
    @State private var solved: Set<String> = []
    @State private var finishedAt: Date?
    @State private var confirmEnd = false

    enum Pane: String, CaseIterable, Identifiable {
        case problem = "Problem", code = "Code"
        var id: Self { self }
    }

    private var problem: Problem { session.problems[current] }
    private var hintsUsed: Int { hintsShown.values.reduce(0, +) }

    var body: some View {
        NavigationStack {
            Group {
                if let finishedAt {
                    InterviewSummaryView(session: session, solved: solved, seconds: Int(finishedAt.timeIntervalSince(start)), hintsUsed: hintsUsed) {
                        dismiss()
                    }
                } else {
                    live
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(finishedAt == nil ? "Interview" : "Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if finishedAt == nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("End", role: .destructive) { confirmEnd = true }
                            .foregroundStyle(Theme.hard)
                    }
                    ToolbarItem(placement: .principal) { timer }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Submit") { finish() }
                            .fontWeight(.semibold)
                    }
                }
            }
            .confirmationDialog("End the interview now?", isPresented: $confirmEnd, titleVisibility: .visible) {
                Button("End and see results", role: .destructive) { finish() }
            }
        }
        .interactiveDismissDisabled()
    }

    private var timer: some View {
        TimelineView(.periodic(from: start, by: 1)) { context in
            let remaining = session.limit - Int(context.date.timeIntervalSince(start))
            Label(InterviewClock.format(remaining), systemImage: remaining < 0 ? "exclamationmark.triangle.fill" : "timer")
                .font(.headline.monospacedDigit())
                .foregroundStyle(remaining < 0 ? Theme.hard : remaining < 300 ? Theme.medium : .primary)
                .contentTransition(.numericText(countsDown: true))
        }
    }

    private var live: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                if session.problems.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(Array(session.problems.enumerated()), id: \.offset) { index, item in
                            Button {
                                withAnimation(.snappy) { current = index }
                            } label: {
                                HStack(spacing: 6) {
                                    SwapIcon(solved.contains(item.id) ? "checkmark.circle.fill" : "\(index + 1).circle")
                                    Text(item.difficulty.rawValue)
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .foregroundStyle(current == index ? .white : .primary)
                                .background(current == index ? AnyShapeStyle(item.difficulty.color.oklchGradient) : AnyShapeStyle(Theme.card),
                                            in: .rounded(Radius.control))
                                .overlay(RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                                    .strokeBorder(current == index ? AnyShapeStyle(.white.opacity(0.2)) : AnyShapeStyle(Theme.stroke), lineWidth: 0.75))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Picker("Pane", selection: $pane.animation(.snappy)) {
                    ForEach(Pane.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            switch pane {
            case .problem:
                ScrollView { statement.padding(16) }
                    .safeAreaInset(edge: .bottom) { solvedBar }
            case .code:
                VStack(spacing: 0) {
                    EditorHeader(fileName: "interview.py") {
                        Button {
                            withAnimation(.spring) { toggleSolved() }
                        } label: {
                            Label(solved.contains(problem.id) ? "Solved" : "Mark solved",
                                  systemImage: solved.contains(problem.id) ? "checkmark.seal.fill" : "checkmark.seal")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(solved.contains(problem.id) ? Theme.easy : CodeTheme.plain)
                                .fixedSize()
                        }
                    }
                    CodeEditor(text: codeBinding, fontSize: fontSize, autoPair: autoPair)
                        .id(problem.id)
                }
                .background(CodeTheme.background.ignoresSafeArea(edges: .bottom))
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16, style: .continuous))
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
    }

    private var statement: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                DifficultyPill(difficulty: problem.difficulty)
                Text("Topic hidden, just like a real interview")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(problem.title).font(.title2.weight(.bold))
            MarkdownText(problem.description).lineSpacing(4)
            ForEach(Array(problem.examples.enumerated()), id: \.offset) { index, example in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Example \(index + 1)").font(.subheadline.weight(.bold))
                    Text("Input: \(example.input)\nOutput: \(example.output)")
                        .font(.callout.monospaced())
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.elevated, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                }
            }
            if !problem.constraints.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Constraints").font(.subheadline.weight(.bold))
                    ForEach(problem.constraints, id: \.self) {
                        Text("• \($0)").font(.callout.monospaced()).foregroundStyle(.secondary)
                    }
                }
            }
            let shown = hintsShown[problem.id] ?? 0
            ForEach(0..<shown, id: \.self) { index in
                Label {
                    MarkdownText(problem.hints[index]).font(.subheadline)
                } icon: {
                    Image(systemName: "lightbulb.fill").foregroundStyle(Theme.insight)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.yellow.color.opacity(0.12), in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            }
            if shown < problem.hints.count {
                Button {
                    withAnimation(.spring) { hintsShown[problem.id] = shown + 1 }
                } label: {
                    Label("Ask for a hint (counts against you)", systemImage: "lightbulb")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.yellow)
                }
            }
        }
    }

    private var solvedBar: some View {
        let isSolved = solved.contains(problem.id)
        return HStack(spacing: 12) {
            Button {
                withAnimation(.spring) { toggleSolved() }
            } label: {
                HStack(spacing: 8) {
                    SwapIcon(isSolved ? "checkmark.seal.fill" : "checkmark.circle")
                    Text(isSolved ? "Solved" : "I solved it")
                }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(isSolved ? Theme.easy : .white)
                    .background(isSolved ? AnyShapeStyle(Theme.easy.opacity(0.15)) : AnyShapeStyle(Theme.brandGradient),
                                in: RoundedRectangle(cornerRadius: Radius.control + 2, style: .continuous))
            }
            .buttonStyle(PressableStyle())
            Button {
                withAnimation(.snappy) { pane = .code }
            } label: {
                Image(systemName: "keyboard")
                    .font(.headline)
                    .frame(width: 54, height: 50)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: Radius.control + 2, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var codeBinding: Binding<String> {
        let id = problem.id
        let starter = problem.starterCode
        return Binding(get: { code[id] ?? starter }, set: { code[id] = $0 })
    }

    private func toggleSolved() {
        if solved.contains(problem.id) { solved.remove(problem.id) } else { solved.insert(problem.id) }
        if solved.count == session.problems.count {
            return
        }
        if solved.contains(problem.id), let next = session.problems.indices.first(where: { !solved.contains(session.problems[$0].id) }) {
            current = next
            pane = .problem
        }
    }

    private func finish() {
        let end = Date()
        let seconds = Int(end.timeIntervalSince(start))
        store.recordInterview(InterviewRecord(
            date: start, problemIDs: session.problems.map(\.id), solvedIDs: session.problems.map(\.id).filter(solved.contains),
            seconds: seconds, limitSeconds: session.limit, hintsUsed: hintsUsed))
        for item in session.problems where solved.contains(item.id) && !store.isSolved(item) {
            store.toggleSolved(item)
        }
        withAnimation(.spring) { finishedAt = end }
    }
}

private struct InterviewSummaryView: View {
    let session: InterviewSession
    let solved: Set<String>
    let seconds: Int
    let hintsUsed: Int
    let done: () -> Void

    private var passed: Bool { solved.count == session.problems.count && seconds <= session.limit }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Image(systemName: passed ? "trophy.fill" : "figure.walk.motion")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(passed ? AnyShapeStyle(Palette.yellow.color.oklchGradient) : AnyShapeStyle(Theme.brandGradient))
                        .symbolEffect(.bounce, value: passed)
                    Text(passed ? "Strong hire!" : "Good practice")
                        .font(.title.weight(.bold))
                    Text(verdict)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                HStack(spacing: 10) {
                    tile("Solved", "\(solved.count)/\(session.problems.count)", "checkmark.circle.fill", Theme.easy)
                    tile("Time", InterviewClock.format(seconds), "timer", seconds > session.limit ? Theme.hard : Theme.accent)
                    tile("Hints", "\(hintsUsed)", "lightbulb.fill", Theme.insight)
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("Review the solutions", icon: "book.pages")
                    ForEach(session.problems) { problem in
                        NavigationLink(value: problem) {
                            HStack(spacing: 12) {
                                Image(systemName: solved.contains(problem.id) ? "checkmark.circle.fill" : "xmark.circle")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(solved.contains(problem.id) ? Theme.easy : Theme.hard)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(problem.title).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                                    Text(problem.topic.name).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                        if let insight = problem.insight {
                            InsightCard(text: insight)
                        }
                    }
                }
                .card()

                Button(action: done) {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: Radius.control + 2, style: .continuous))
                }
                .buttonStyle(PressableStyle())
            }
            .padding(16)
        }
        .appDestinations()
    }

    private var verdict: String {
        if passed {
            return hintsUsed == 0 ? "Every problem solved in time with no hints. That's interview-ready." : "Every problem solved in time. Next time, try it without hints."
        }
        if solved.count == session.problems.count {
            return "You solved everything but went over time. Speed comes from recognizing patterns faster, so keep reviewing."
        }
        return "Study the solutions below, then come back to them in your daily review."
    }

    private func tile(_ label: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.headline.monospacedDigit())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 12)
    }
}
