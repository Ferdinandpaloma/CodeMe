import SwiftUI

/// A paged mini-course: concept sections followed by quick-check questions.
struct LessonView: View {
    let lesson: Lesson
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var page = 0
    @State private var answers: [Int: Int] = [:]

    private var sectionCount: Int { lesson.sections.count }
    private var pageCount: Int { sectionCount + lesson.quiz.count + 1 }
    private var isFinish: Bool { page == pageCount - 1 }
    private var quizIndex: Int? {
        page >= sectionCount && page < sectionCount + lesson.quiz.count ? page - sectionCount : nil
    }
    private var canContinue: Bool {
        guard let quizIndex else { return true }
        return answers[quizIndex] != nil
    }
    private var correctCount: Int {
        lesson.quiz.indices.filter { answers[$0] == lesson.quiz[$0].answer }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= page ? AnyShapeStyle(lesson.color.gradient) : AnyShapeStyle(Color.primary.opacity(0.1)))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .animation(.snappy, value: page)

            ScrollView {
                Group {
                    if page < sectionCount {
                        sectionPage(lesson.sections[page], number: page + 1)
                    } else if let quizIndex {
                        quizPage(lesson.quiz[quizIndex], index: quizIndex)
                    } else {
                        finishPage
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(page)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }
            .scrollBounceBehavior(.basedOnSize)

            bottomBar
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sensoryFeedback(.success, trigger: isFinish) { _, new in new }
    }

    // MARK: Pages

    private func sectionPage(_ section: LessonSection, number: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PART \(number) OF \(sectionCount)")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(lesson.color)
            Text(section.heading)
                .font(.title2.weight(.bold))
            MarkdownText(section.body)
                .font(.body)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
            if let code = section.code {
                CodeBlockView(code: code, fileName: "example.py")
            }
        }
    }

    private func quizPage(_ question: QuizQuestion, index: Int) -> some View {
        let chosen = answers[index]
        return VStack(alignment: .leading, spacing: 16) {
            Label("QUICK CHECK \(index + 1) OF \(lesson.quiz.count)", systemImage: "checkmark.bubble.fill")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(lesson.color)
            MarkdownText(question.prompt)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(question.options.indices, id: \.self) { option in
                    let state = optionState(option, chosen: chosen, answer: question.answer)
                    Button {
                        guard chosen == nil else { return }
                        withAnimation(.spring(duration: 0.35)) { answers[index] = option }
                    } label: {
                        HStack(spacing: 12) {
                            Text(String(UnicodeScalar(65 + option)!))
                                .font(.subheadline.weight(.bold))
                                .frame(width: 28, height: 28)
                                .background(state.border.opacity(state == .idle ? 0.25 : 1), in: Circle())
                                .foregroundStyle(state == .idle ? Color.primary : .white)
                            MarkdownText(question.options[option])
                                .font(.subheadline.weight(.medium))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.primary)
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(state.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(state.border, lineWidth: state == .correct || state == .wrong ? 2 : 1))
                        .opacity(state == .dimmed ? 0.5 : 1)
                    }
                    .buttonStyle(PressableStyle())
                }
            }

            if let chosen {
                let right = chosen == question.answer
                VStack(alignment: .leading, spacing: 8) {
                    Label(right ? "Correct!" : "Not quite", systemImage: right ? "sparkles" : "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(right ? Theme.easy : Theme.medium)
                    MarkdownText(question.explanation)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .card()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sensoryFeedback(trigger: chosen) { _, new in
            guard let new else { return nil }
            return new == question.answer ? .success : .error
        }
    }

    private var finishPage: some View {
        VStack(spacing: 18) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 56))
                .foregroundStyle(lesson.color.gradient)
                .padding(26)
                .background(lesson.color.opacity(0.12), in: Circle())
                .symbolEffect(.bounce, value: isFinish)
            Text("Lesson complete!")
                .font(.title.weight(.bold))
            Text("You got \(correctCount) of \(lesson.quiz.count) quick checks right.")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(lesson.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .onAppear { store.completeLesson(lesson) }
    }

    // MARK: Bottom bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if page > 0 && !isFinish {
                Button {
                    withAnimation(.snappy) { page -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 54, height: 52)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.stroke, lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
            }
            Button {
                if isFinish {
                    dismiss()
                } else {
                    withAnimation(.spring(duration: 0.4)) { page += 1 }
                }
            } label: {
                Text(isFinish ? "Done" : (quizIndex != nil && !canContinue ? "Choose an answer" : "Continue"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(lesson.color.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .opacity(canContinue ? 1 : 0.45)
            }
            .buttonStyle(PressableStyle())
            .disabled(!canContinue)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.bar)
    }

    private func optionState(_ option: Int, chosen: Int?, answer: Int) -> OptionState {
        guard let chosen else { return .idle }
        if option == answer { return .correct }
        if option == chosen { return .wrong }
        return .dimmed
    }
}

/// Shared answer-state styling for multiple-choice questions.
enum OptionState: Equatable {
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

/// Entry point card for a lesson.
struct LessonCard: View {
    let lesson: Lesson
    @Environment(ProgressStore.self) private var store

    var body: some View {
        let done = store.isComplete(lesson)
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(lesson.color.gradient)
                Image(systemName: "book.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text("LESSON · \(lesson.minutes) MIN")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(lesson.color)
                Text(lesson.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(lesson.sections.count) parts · \(lesson.quiz.count) quick checks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if done {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.easy)
            } else {
                Text("Start")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(lesson.color.gradient, in: Capsule())
            }
        }
        .card(padding: 14)
    }
}
