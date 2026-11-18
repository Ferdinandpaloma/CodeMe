import SwiftUI

struct TopicDetailView: View {
    let topic: Topic
    @Environment(ProgressStore.self) private var store

    var body: some View {
        let problems = ProblemBank.problems(for: topic)
        let done = store.solvedCount(in: topic)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        TopicIcon(topic: topic, size: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(topic.name)
                                .font(.title3.weight(.bold))
                            Text("\(done) of \(problems.count) solved")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    ProgressBar(progress: problems.isEmpty ? 0 : Double(done) / Double(problems.count), color: topic.color, height: 8)
                    Text(topic.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .card()

                NavigationLink(value: topic.lesson) {
                    LessonCard(lesson: topic.lesson)
                }
                .buttonStyle(PressableStyle())

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("Spot the pattern", icon: "eye")
                    ForEach(topic.signals, id: \.self) { signal in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Image(systemName: "sparkle")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(topic.color)
                            MarkdownText(signal)
                                .font(.subheadline)
                        }
                    }
                }
                .card()

                SectionHeader("Pattern template", icon: "chevron.left.forwardslash.chevron.right")
                CodeBlockView(code: topic.template, fileName: "template.py")

                SectionHeader("Problems", icon: "list.bullet")
                VStack(spacing: 0) {
                    ForEach(problems) { problem in
                        NavigationLink(value: problem) {
                            ProblemRow(problem: problem, showTopic: false)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                        if problem != problems.last {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .card(padding: 0)
            }
            .padding(16)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
