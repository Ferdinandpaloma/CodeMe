import SwiftUI

/// "Pattern Trainer": read a problem statement and identify which pattern solves it.
struct QuizView: View {
    @Environment(ProgressStore.self) private var store

    @State private var question: Problem = ProblemBank.all[0]
    @State private var options: [Topic] = []
    @State private var picked: Topic?
    @State private var score = 0
    @State private var answered = 0
    @State private var streak = 0

    private var isCorrect: Bool { picked == question.topic }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Pattern Trainer")
            .appDestinations()
            .onAppear {
                if options.isEmpty { nextQuestion() }
            }
            .sensoryFeedback(trigger: picked) { _, new in
                guard let new else { return nil }
                return new == question.topic ? .success : .error
            }
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
                Text("WHICH PATTERN SOLVES THIS?")
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.accent)
                Spacer()
                DifficultyPill(difficulty: question.difficulty)
            }
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
        }
        .card()
        .id(question.id)
    }

    private func optionButton(_ option: Topic) -> some View {
        let state: OptionState = {
            guard let picked else { return .idle }
            if option == question.topic { return .correct }
            if option == picked { return .wrong }
            return .dimmed
        }()

        return Button {
            choose(option)
        } label: {
            HStack(spacing: 12) {
                TopicIcon(topic: option, size: 34)
                Text(option.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
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
            MarkdownText("**\(question.title)** is a **\(question.topic.name)** problem. \(question.approach.first ?? "")")
                .font(.subheadline)
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

    private func choose(_ option: Topic) {
        guard picked == nil else { return }
        withAnimation(.spring(duration: 0.35)) {
            picked = option
            answered += 1
            if option == question.topic {
                score += 1
                streak += 1
                store.recordQuizStreak(streak)
            } else {
                streak = 0
            }
        }
    }

    private func nextQuestion() {
        var next = ProblemBank.all.randomElement()!
        while next == question, ProblemBank.all.count > 1 {
            next = ProblemBank.all.randomElement()!
        }
        var choices: Set<Topic> = [next.topic]
        while choices.count < 4 {
            choices.insert(Topic.allCases.randomElement()!)
        }
        question = next
        options = Array(choices).shuffled()
        picked = nil
    }
}

private enum OptionState: Equatable {
    case idle, correct, wrong, dimmed

    var background: Color {
        switch self {
        case .correct: Theme.easy.opacity(0.12)
        case .wrong: Theme.hard.opacity(0.12)
        default: Theme.card
        }
    }

    var border: Color {
        switch self {
        case .correct: Theme.easy
        case .wrong: Theme.hard
        default: Theme.stroke
        }
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
