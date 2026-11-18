import SwiftUI

enum QuizMode: String, Hashable {
    case pattern, complexity

    var title: String {
        switch self {
        case .pattern: "Pattern Trainer"
        case .complexity: "Complexity Quiz"
        }
    }

    var prompt: String {
        switch self {
        case .pattern: "WHICH PATTERN SOLVES THIS?"
        case .complexity: "WHAT'S THE TIME COMPLEXITY?"
        }
    }
}

private struct QuizOption: Identifiable, Hashable {
    let id: String
    let label: String
    var topic: Topic? = nil
}

/// Multiple-choice drills generated from the problem bank.
struct QuizView: View {
    let mode: QuizMode
    @Environment(ProgressStore.self) private var store

    @State private var question: Problem = ProblemBank.all[0]
    @State private var options: [QuizOption] = []
    @State private var picked: String?
    @State private var score = 0
    @State private var answered = 0
    @State private var streak = 0

    /// Complexity classes used as answers; only problems whose time is one of these are asked.
    private static let complexityClasses = ["O(1)", "O(log n)", "O(n)", "O(n log n)", "O(n log k)", "O(n²)", "O(n · 2ⁿ)", "O(n · n!)"]

    private var pool: [Problem] {
        switch mode {
        case .pattern: ProblemBank.all
        case .complexity: ProblemBank.all.filter { Self.complexityClasses.contains($0.time) }
        }
    }

    private var correctID: String {
        mode == .pattern ? question.topic.rawValue : question.time
    }

    private var isCorrect: Bool { picked == correctID }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statsRow
                questionCard
                VStack(spacing: 10) {
                    ForEach(options) { option in
                        optionButton(option)
                    }
                }
                if picked != nil {
                    feedbackCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if options.isEmpty { nextQuestion() }
        }
        .sensoryFeedback(trigger: picked) { _, new in
            guard let new else { return nil }
            return new == correctID ? .success : .error
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            QuizStat(icon: "target", value: "\(score)/\(answered)", label: "Score", color: Theme.accent)
            QuizStat(icon: "flame.fill", value: "\(streak)", label: "Streak", color: .orange)
            QuizStat(icon: "crown.fill", value: "\(store.bestQuizStreak)", label: "Best", color: .yellow)
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mode.prompt)
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.accent)
                Spacer()
                DifficultyPill(difficulty: question.difficulty)
            }
            switch mode {
            case .pattern:
                if picked != nil {
                    Text(question.title)
                        .font(.title3.weight(.bold))
                        .transition(.opacity)
                }
                MarkdownText(question.description)
                    .font(.callout)
                    .lineSpacing(3)
                if let example = question.examples.first {
                    Text(example.input)
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.elevated, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            case .complexity:
                Text(question.title)
                    .font(.title3.weight(.bold))
                Text("n is the size of the input.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                CodeBlockView(code: question.solution)
            }
        }
        .card()
        .id(question.id)
    }

    private func optionButton(_ option: QuizOption) -> some View {
        let state: OptionState = {
            guard let picked else { return .idle }
            if option.id == correctID { return .correct }
            if option.id == picked { return .wrong }
            return .dimmed
        }()

        return Button {
            choose(option)
        } label: {
            HStack(spacing: 12) {
                if let topic = option.topic {
                    TopicIcon(topic: topic, size: 34)
                    Text(option.label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                } else {
                    Text(option.label)
                        .font(.body.monospaced().weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.vertical, 6)
                        .padding(.leading, 4)
                }
                Spacer()
                switch state {
                case .correct:
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.easy).transition(.scale)
                case .wrong:
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.hard).transition(.scale)
                default:
                    EmptyView()
                }
            }
            .font(.title3)
            .padding(12)
            .background(state.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(state.border, lineWidth: state == .idle || state == .dimmed ? 1 : 2))
            .opacity(state == .dimmed ? 0.5 : 1)
        }
        .buttonStyle(PressableStyle())
        .disabled(picked != nil)
    }

    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(isCorrect ? "Nice! That's right." : "Not quite.", systemImage: isCorrect ? "sparkles" : "arrow.triangle.2.circlepath")
                .font(.headline)
                .foregroundStyle(isCorrect ? Theme.easy : Theme.hard)
            switch mode {
            case .pattern:
                MarkdownText("**\(question.title)** is a **\(question.topic.name)** problem.")
                    .font(.subheadline)
            case .complexity:
                MarkdownText("**\(question.title)** runs in **\(question.time)** time and **\(question.space)** space.")
                    .font(.subheadline)
            }
            if let insight = question.insight {
                InsightCard(text: insight)
            }
            HStack(spacing: 10) {
                NavigationLink(value: question) {
                    Text("Study it")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                Button {
                    withAnimation(.spring(duration: 0.45)) { nextQuestion() }
                } label: {
                    Label("Next", systemImage: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PressableStyle())
            }
        }
        .card()
    }

    private func choose(_ option: QuizOption) {
        guard picked == nil else { return }
        withAnimation(.spring(duration: 0.35)) {
            picked = option.id
            answered += 1
            if option.id == correctID {
                score += 1
                streak += 1
                store.recordQuizStreak(streak)
            } else {
                streak = 0
            }
        }
    }

    private func nextQuestion() {
        let candidates = pool
        var next = candidates.randomElement()!
        while next == question, candidates.count > 1 {
            next = candidates.randomElement()!
        }
        question = next

        switch mode {
        case .pattern:
            var choices: Set<Topic> = [next.topic]
            while choices.count < 4 { choices.insert(Topic.allCases.randomElement()!) }
            options = choices.shuffled().map { QuizOption(id: $0.rawValue, label: $0.name, topic: $0) }
        case .complexity:
            let distractors = Self.complexityClasses.filter { $0 != next.time }.shuffled().prefix(3)
            options = ([next.time] + distractors).shuffled().map { QuizOption(id: $0, label: $0) }
        }
        picked = nil
    }
}

private struct QuizStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline.monospacedDigit())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 12)
    }
}
