import SwiftUI

enum PracticeRoute: Hashable {
    case review
    case quiz(QuizMode)
    case drill(DrillMode)
    case interview
}

/// Practice hub: spaced-repetition review, drills, and lessons.
struct PracticeView: View {
    @Environment(ProgressStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    reviewCard

                    NavigationLink(value: PracticeRoute.interview) {
                        interviewCard
                    }
                    .buttonStyle(PressableStyle())

                    SectionHeader("Drills", icon: "dumbbell.fill")
                        .padding(.top, 4)
                    NavigationLink(value: PracticeRoute.quiz(.pattern)) {
                        ModeCard(icon: "brain.head.profile", title: "Pattern Trainer",
                                 subtitle: "Read a problem statement and name the pattern that solves it.",
                                 color: Theme.accent)
                    }
                    .buttonStyle(PressableStyle())
                    NavigationLink(value: PracticeRoute.quiz(.complexity)) {
                        ModeCard(icon: "speedometer", title: "Complexity Quiz",
                                 subtitle: "Read a Python solution and pick its time complexity.",
                                 color: Palette.pink.color)
                    }
                    .buttonStyle(PressableStyle())
                    NavigationLink(value: PracticeRoute.drill(.fillBlank)) {
                        ModeCard(icon: "rectangle.and.pencil.and.ellipsis", title: "Fill the Blank",
                                 subtitle: "A line is missing from a solution. Pick the one that belongs.",
                                 color: Palette.lime.color)
                    }
                    .buttonStyle(PressableStyle())
                    NavigationLink(value: PracticeRoute.drill(.lineOrder)) {
                        ModeCard(icon: "text.line.first.and.arrowtriangle.forward", title: "Line Order",
                                 subtitle: "Rebuild a scrambled solution line by line.",
                                 color: Palette.orange.color)
                    }
                    .buttonStyle(PressableStyle())

                    SectionHeader("Reference", icon: "books.vertical.fill")
                        .padding(.top, 4)
                    ForEach(ReferenceSheet.allCases) { sheet in
                        NavigationLink(value: sheet) {
                            ReferenceCard(sheet: sheet)
                        }
                        .buttonStyle(PressableStyle())
                    }

                    HStack {
                        SectionHeader("Lessons", icon: "book.fill")
                        Text("\(LessonBank.all.filter(store.isComplete).count)/\(LessonBank.all.count) done")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.secondary)
                            .fixedSize()
                    }
                    .padding(.top, 4)
                    ForEach(LessonBank.all) { lesson in
                        NavigationLink(value: lesson) {
                            LessonCard(lesson: lesson)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Practice")
            .navigationDestination(for: PracticeRoute.self) { route in
                switch route {
                case .review: ReviewSessionView()
                case .quiz(let mode): QuizView(mode: mode)
                case .drill(let mode): DrillView(mode: mode)
                case .interview: InterviewSetupView()
                }
            }
            .appDestinations()
        }
    }

    private var reviewCard: some View {
        let due = store.dueReviews.count
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DAILY REVIEW")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .vibrant(0.75)
                    Text(due == 0 ? "All caught up" : "\(due) problem\(due == 1 ? "" : "s") due")
                        .font(.title2.weight(.bold))
                        .contentTransition(.numericText())
                    Text(reviewSubtitle(due: due))
                        .font(.subheadline)
                        .vibrant(0.88)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                SwapIcon(due == 0 ? "checkmark.circle" : "arrow.triangle.2.circlepath")
                    .font(.system(size: 30, weight: .bold))
                    .vibrant(0.9)
            }
            if due > 0 {
                NavigationLink(value: PracticeRoute.review) {
                    Label("Start Review", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white, in: .rounded(Radius.control))
                }
                .buttonStyle(PressableStyle())
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AuroraBackground(stops: Theme.heroStops))
        .compositingGroup()
        // Start button: control radius at 20pt inset -> concentric outer radius.
        .clipShape(.rounded(Radius.outer(padding: 20)))
        .overlay(RoundedRectangle(cornerRadius: Radius.outer(padding: 20), style: .continuous)
            .strokeBorder(LinearGradient(colors: [.white.opacity(0.35), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom), lineWidth: 0.75)
            .blendMode(.plusLighter))
        .shadow(color: Palette.violet.opacity(0.3).color, radius: 16, y: 8)
    }

    private var interviewCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.2), in: .rounded(Radius.control))
                .overlay(RoundedRectangle(cornerRadius: Radius.control, style: .continuous).strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
            VStack(alignment: .leading, spacing: 3) {
                Text("MOCK INTERVIEW")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .vibrant(0.75)
                Text("Timed, topic hidden")
                    .font(.headline)
                Text(store.interviews.isEmpty ? "Practice under real pressure." : "\(store.interviews.count) done · \(store.interviews.filter(\.passed).count) passed")
                    .font(.caption)
                    .vibrant(0.85)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").font(.footnote.weight(.bold)).vibrant(0.7)
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AuroraBackground(stops: [Palette.orange, Palette.red, Palette.pink], glow: Palette.amber))
        .compositingGroup()
        .clipShape(.rounded(Radius.outer(padding: 16)))
        .overlay(RoundedRectangle(cornerRadius: Radius.outer(padding: 16), style: .continuous)
            .strokeBorder(.white.opacity(0.2), lineWidth: 0.75).blendMode(.plusLighter))
    }

    private func reviewSubtitle(due: Int) -> String {
        if due > 0 {
            return "Recall the pattern and key insight before peeking. Spaced repetition makes it stick."
        }
        if let next = store.nextReviewDate {
            return "Next review \(next.formatted(.relative(presentation: .named))). Solved problems come back right before you'd forget them."
        }
        return "Mark problems as solved and they'll come back here on a spaced-repetition schedule."
    }
}

private struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(color.oklchGradient, in: .rounded(Radius.control))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .card(padding: 14)
    }
}

// MARK: - Review session

struct ReviewSessionView: View {
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var queue: [Problem] = []
    @State private var started = false
    @State private var position = 0
    @State private var revealed = false
    @State private var reviewedCount = 0

    var body: some View {
        VStack(spacing: 0) {
            if position < queue.count {
                let problem = queue[position]
                ProgressBar(progress: Double(position) / Double(max(queue.count, 1)), color: Theme.accent, height: 4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                ScrollView {
                    card(for: problem)
                        .padding(16)
                        .id(problem.id)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                }
                bottomBar(for: problem)
            } else if started {
                doneView
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(queue.isEmpty ? "Review" : "Review \(min(position + 1, queue.count)) of \(queue.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            guard !started else { return }
            queue = store.dueReviews
            started = true
        }
    }

    private func card(for problem: Problem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("#\(problem.number)")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.secondary)
                DifficultyPill(difficulty: problem.difficulty)
                if revealed { TopicChip(topic: problem.topic).transition(.scale.combined(with: .opacity)) }
            }
            Text(problem.title)
                .font(.title2.weight(.bold))
            MarkdownText(problem.description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            if revealed {
                if let insight = problem.insight {
                    InsightCard(text: insight)
                }
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Approach", icon: "point.topleft.down.to.point.bottomright.curvepath")
                    ForEach(Array(problem.approach.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1).")
                                .font(.subheadline.weight(.bold).monospacedDigit())
                                .foregroundStyle(Theme.accent)
                            MarkdownText(step).font(.subheadline)
                        }
                    }
                }
                .card()
                CodeBlockView(code: problem.solution)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Before you reveal, try to recall:", systemImage: "brain")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    ForEach(["Which pattern does this use?", "What's the key insight or trick?", "Can you outline the code and its complexity?"], id: \.self) { prompt in
                        Label(prompt, systemImage: "circle")
                            .font(.subheadline)
                            .labelStyle(PromptLabelStyle())
                    }
                }
                .card()
            }
        }
    }

    @ViewBuilder
    private func bottomBar(for problem: Problem) -> some View {
        Group {
            if revealed {
                VStack(spacing: 8) {
                    Text("How well did you remember it?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(ReviewGrade.allCases) { grade in
                            Button {
                                rate(problem, grade)
                            } label: {
                                VStack(spacing: 2) {
                                    Text(grade.label).font(.subheadline.weight(.bold))
                                    Text(intervalLabel(store.interval(for: problem, grade: grade)))
                                        .font(.caption2.monospacedDigit())
                                        .opacity(0.8)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(gradeColor(grade).oklchGradient, in: .rounded(Radius.control))
                            }
                            .buttonStyle(PressableStyle())
                        }
                    }
                }
            } else {
                Button {
                    withAnimation(.spring(duration: 0.45)) { revealed = true }
                } label: {
                    Label("Show Answer", systemImage: "eye.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.brandGradient, in: .rounded(Radius.control + 2))
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.bar)
    }

    private var doneView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(Theme.easy.oklchGradient)
                .symbolEffect(.bounce, value: started)
            Text(reviewedCount > 0 ? "Review complete!" : "Nothing due right now")
                .font(.title2.weight(.bold))
            Text(reviewedCount > 0 ? "You reviewed \(reviewedCount) problem\(reviewedCount == 1 ? "" : "s"). They'll come back when it's time to refresh them." : "Solve more problems to grow your review deck.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Back to Practice") { dismiss() }
                .font(.headline)
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func rate(_ problem: Problem, _ grade: ReviewGrade) {
        store.review(problem, grade: grade)
        reviewedCount += 1
        withAnimation(.spring(duration: 0.45)) {
            revealed = false
            position += 1
        }
    }

    private func intervalLabel(_ days: Int) -> String {
        days < 30 ? "\(days)d" : "\(days / 30)mo"
    }

    private func gradeColor(_ grade: ReviewGrade) -> Color {
        switch grade {
        case .again: Theme.hard
        case .hard: Theme.medium
        case .good: Theme.easy
        case .easy: Palette.sky.color
        }
    }
}

private struct PromptLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(Theme.accent.opacity(0.7))
            configuration.title
        }
    }
}

/// Highlighted "key insight" callout.
struct InsightCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.max.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.insight)
            VStack(alignment: .leading, spacing: 4) {
                Text("KEY INSIGHT")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.insight)
                MarkdownText(text)
                    .font(.subheadline.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.yellow.color.opacity(0.12), in: .rounded(Radius.outer(padding: 14)))
        .overlay(RoundedRectangle(cornerRadius: Radius.outer(padding: 14), style: .continuous).strokeBorder(Palette.yellow.opacity(0.4).color, lineWidth: 0.75))
    }
}
