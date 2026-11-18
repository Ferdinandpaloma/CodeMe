import SwiftUI

struct RoadmapView: View {
    @Environment(ProgressStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeroCard()
                    DailyCard()
                    UpNextCard()
                    SectionHeader("Start here", icon: "graduationcap.fill")
                        .padding(.top, 4)
                    ForEach(LessonBank.fundamentals) { lesson in
                        NavigationLink(value: lesson) {
                            LessonCard(lesson: lesson)
                        }
                        .buttonStyle(PressableStyle())
                    }
                    SectionHeader("Roadmap", icon: "map")
                        .padding(.top, 4)
                    roadmapTree
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("CodeMe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
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
                .fill(OKGradient.linear(Theme.brandStops.map { $0.opacity(0.65) }, start: .top, end: .bottom))
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
                        .vibrant(0.7)
                    Text("Master the patterns")
                        .font(.title2.weight(.bold))
                    Text("\(solved) of \(total) problems solved")
                        .font(.subheadline)
                        .vibrant(0.85)
                }
                Spacer()
                ZStack {
                    ProgressRing(progress: progress, lineWidth: 8, track: .white.opacity(0.28), fill: AnyShapeStyle(Color.white))
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                }
                .aspectRatio(1, contentMode: .fit)
                .viewportWidth(0.18, min: 60, max: 84)
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
                AuroraBackground(stops: Theme.heroStops)
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 180)
                    .offset(x: 130, y: -70)
                    .blendMode(.overlay)
                Circle()
                    .fill(.white.opacity(0.14))
                    .frame(width: 120)
                    .offset(x: -150, y: 70)
                    .blendMode(.softLight)
            }
            .compositingGroup()
        }
        .compositingGroup()
        // Badges are capsules inset 20pt; the card is control radius + padding.
        .clipShape(.rounded(Radius.outer(padding: 20)))
        .overlay(RoundedRectangle(cornerRadius: Radius.outer(padding: 20), style: .continuous)
            .strokeBorder(LinearGradient(colors: [.white.opacity(0.35), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom), lineWidth: 0.75)
            .blendMode(.plusLighter))
        .shadow(color: Palette.violet.opacity(0.35).color, radius: 18, y: 8)
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
            .overlay(Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 0.5))
    }
}

private struct DailyCard: View {
    @Environment(ProgressStore.self) private var store
    @AppStorage(SettingsKey.dailyGoal) private var goal = SettingsKey.defaultDailyGoal

    var body: some View {
        let today = store.solvedToday
        let met = today >= goal
        let daily = store.problemOfTheDay

        HStack(spacing: 14) {
            ZStack {
                ProgressRing(progress: Double(today) / Double(max(goal, 1)), lineWidth: 7,
                             fill: met ? AnyShapeStyle(Theme.easy) : AnyShapeStyle(OKGradient.angular([Palette.orange, Palette.pink])))
                Group {
                    if met {
                        Image(systemName: "checkmark")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Theme.easy)
                    } else {
                        Text("\(today)/\(goal)")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .contentTransition(.numericText())
                    }
                }
                .transition(.blurReplace)
            }
            .frame(width: 58, height: 58)
            .animation(.spring(duration: 0.45), value: met)
            .accessibilityLabel("Daily goal: \(today) of \(goal) problems solved today")

            NavigationLink(value: daily) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "sun.max.fill").foregroundStyle(Palette.orange.color)
                        Text("PROBLEM OF THE DAY")
                            .tracking(1)
                    }
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    Text(daily.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        DifficultyPill(difficulty: daily.difficulty)
                        if store.isSolved(daily) {
                            Label("Done", systemImage: "checkmark.circle.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Theme.easy)
                        } else {
                            Text(met ? "Goal met, bonus round!" : "Daily goal: \(goal)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .card()
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
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Theme.brandGradient)
                }
                .card()
            }
            .buttonStyle(PressableStyle())
        } else {
            HStack(spacing: 14) {
                Image(systemName: "trophy.fill")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Palette.yellow.color)
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
                            .font(.system(size: 16, weight: .semibold))
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
        // Icon tile is 12pt radius at 10pt inset -> 22pt outer.
        .surface(radius: Radius.outer(padding: 10))
        .overlay {
            if complete {
                RoundedRectangle(cornerRadius: Radius.outer(padding: 10), style: .continuous)
                    .strokeBorder(Theme.easy.opacity(0.55), lineWidth: 1.25)
            }
        }
    }
}
