import SwiftUI

struct RoadmapView: View {
    @Environment(ProgressStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeroCard()
                    UpNextCard()
                    SectionHeader("Roadmap", icon: "map")
                        .padding(.top, 4)
                    roadmapTree
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("CodeMe")
            .appDestinations()
        }
    }

    private var roadmapTree: some View {
        VStack(spacing: 0) {
            ForEach(Array(Topic.roadmap.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Connector()
                }
                HStack(spacing: 10) {
                    ForEach(row) { topic in
                        NavigationLink(value: topic) {
                            TopicNode(topic: topic)
                                .containerRelativeFrame(.horizontal) { length, _ in
                                    (length - 32 - 20) / 3
                                }
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
        }
    }
}

private struct Connector: View {
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(LinearGradient(colors: [Theme.accent.opacity(0.6), Theme.accent2.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                .frame(width: 3, height: 22)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}

private struct HeroCard: View {
    @Environment(ProgressStore.self) private var store

    var body: some View {
        let total = ProblemBank.all.count
        let solved = store.solvedCount
        let progress = total == 0 ? 0 : Double(solved) / Double(total)

        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("YOUR JOURNEY")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .opacity(0.75)
                    Text("Master the patterns")
                        .font(.title2.weight(.bold))
                    Text("\(solved) of \(total) problems solved")
                        .font(.subheadline)
                        .opacity(0.85)
                }
                Spacer()
                ZStack {
                    ProgressRing(progress: progress, lineWidth: 8, track: .white.opacity(0.22), fill: AnyShapeStyle(Color.white))
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                }
                .frame(width: 68, height: 68)
            }

            HStack(spacing: 8) {
                HeroBadge(icon: "flame.fill", text: "\(store.currentStreak) day streak")
                HeroBadge(icon: "checkmark.seal.fill", text: "\(store.completedTopics)/\(Topic.allCases.count) topics")
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                Theme.brandGradient
                Circle()
                    .fill(.white.opacity(0.10))
                    .frame(width: 180)
                    .offset(x: 130, y: -70)
                Circle()
                    .fill(.white.opacity(0.07))
                    .frame(width: 120)
                    .offset(x: -150, y: 70)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.accent.opacity(0.35), radius: 18, y: 8)
    }
}

private struct HeroBadge: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.18), in: Capsule())
    }
}

private struct UpNextCard: View {
    @Environment(ProgressStore.self) private var store

    var body: some View {
        if let next = store.nextProblem {
            NavigationLink(value: next) {
                HStack(spacing: 14) {
                    TopicIcon(topic: next.topic, size: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("UP NEXT")
                            .font(.caption2.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(.secondary)
                        Text(next.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        HStack(spacing: 6) {
                            DifficultyPill(difficulty: next.difficulty)
                            Text(next.topic.shortName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Theme.brandGradient)
                }
                .card()
            }
            .buttonStyle(PressableStyle())
        } else {
            HStack(spacing: 14) {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading) {
                    Text("Roadmap complete!").font(.headline)
                    Text("Every problem solved. Try the Pattern Trainer to stay sharp.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .card()
        }
    }
}

private struct TopicNode: View {
    @Environment(ProgressStore.self) private var store
    let topic: Topic

    var body: some View {
        let total = ProblemBank.problems(for: topic).count
        let done = store.solvedCount(in: topic)
        let complete = total > 0 && done == total

        VStack(spacing: 8) {
            TopicIcon(topic: topic, size: 40)
                .overlay(alignment: .topTrailing) {
                    if complete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Theme.easy)
                            .offset(x: 6, y: -6)
                    }
                }
            Text(topic.shortName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(height: 32)
            ProgressBar(progress: total == 0 ? 0 : Double(done) / Double(total), color: topic.color, height: 5)
            Text("\(done) / \(total)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(complete ? Theme.easy.opacity(0.6) : Theme.stroke, lineWidth: complete ? 1.5 : 1)
        )
    }
}
