import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    let color: Color
    /// (current, target)
    let measure: (ProgressStore) -> (Int, Int)

    func progress(_ store: ProgressStore) -> (current: Int, target: Int) {
        let (current, target) = measure(store)
        return (min(current, target), target)
    }

    func isUnlocked(_ store: ProgressStore) -> Bool {
        let (current, target) = measure(store)
        return current >= target
    }
}

enum Achievements {
    static let all: [Achievement] = [
        Achievement(id: "solve-1", title: "Hello, World", detail: "Solve your first problem", icon: "sparkles", color: Theme.accent) {
            ($0.solvedCount, 1)
        },
        Achievement(id: "solve-10", title: "Warming Up", detail: "Solve 10 problems", icon: "flame", color: .orange) {
            ($0.solvedCount, 10)
        },
        Achievement(id: "solve-25", title: "Pattern Hunter", detail: "Solve 25 problems", icon: "scope", color: Palette.sky.color) {
            ($0.solvedCount, 25)
        },
        Achievement(id: "solve-50", title: "Half Century", detail: "Solve 50 problems", icon: "50.circle.fill", color: Palette.violet.color) {
            ($0.solvedCount, 50)
        },
        Achievement(id: "solve-all", title: "Grandmaster", detail: "Solve every problem", icon: "crown.fill", color: .yellow) {
            ($0.solvedCount, ProblemBank.all.count)
        },
        Achievement(id: "easy-all", title: "Easy Peasy", detail: "Solve every Easy problem", icon: "leaf.fill", color: Theme.easy) {
            ($0.solvedCount(.easy), ProblemBank.all.filter { $0.difficulty == .easy }.count)
        },
        Achievement(id: "hard-5", title: "Hard Mode", detail: "Solve 5 Hard problems", icon: "bolt.fill", color: Theme.hard) {
            ($0.solvedCount(.hard), 5)
        },
        Achievement(id: "streak-3", title: "On a Roll", detail: "Reach a 3-day streak", icon: "flame.fill", color: .orange) {
            ($0.currentStreak, 3)
        },
        Achievement(id: "streak-7", title: "Week Warrior", detail: "Reach a 7-day streak", icon: "calendar.badge.checkmark", color: Palette.rose.color) {
            ($0.currentStreak, 7)
        },
        Achievement(id: "topic-1", title: "Topic Cleared", detail: "Finish every problem in a topic", icon: "checkmark.seal.fill", color: Theme.easy) {
            ($0.completedTopics, 1)
        },
        Achievement(id: "topic-6", title: "Well Rounded", detail: "Finish 6 topics", icon: "square.grid.3x3.fill", color: Palette.teal.color) {
            ($0.completedTopics, 6)
        },
        Achievement(id: "lessons-5", title: "Student", detail: "Complete 5 lessons", icon: "book.fill", color: Palette.indigo.color) {
            ($0.completedLessons.count, 5)
        },
        Achievement(id: "lessons-all", title: "Scholar", detail: "Complete every lesson", icon: "graduationcap.fill", color: Palette.indigo.color) {
            ($0.completedLessons.count, LessonBank.all.count)
        },
        Achievement(id: "reviews-10", title: "Memory Palace", detail: "Grade 10 spaced reviews", icon: "arrow.triangle.2.circlepath", color: Theme.accent2) {
            ($0.totalReviews, 10)
        },
        Achievement(id: "reviews-50", title: "Total Recall", detail: "Grade 50 spaced reviews", icon: "brain.head.profile", color: Theme.accent2) {
            ($0.totalReviews, 50)
        },
        Achievement(id: "quiz-10", title: "Sharp Eye", detail: "Get a 10-answer quiz streak", icon: "eye.fill", color: Palette.pink.color) {
            ($0.bestQuizStreak, 10)
        },
        Achievement(id: "drills-25", title: "Muscle Memory", detail: "Answer 25 code drills correctly", icon: "keyboard.fill", color: Palette.lime.color) {
            ($0.drillCorrect, 25)
        },
        Achievement(id: "interview-1", title: "In the Hot Seat", detail: "Finish a mock interview", icon: "timer", color: Theme.medium) {
            ($0.interviews.count, 1)
        },
        Achievement(id: "interview-pass", title: "Offer Letter", detail: "Solve every problem in a mock interview in time", icon: "envelope.open.fill", color: Theme.easy) {
            ($0.interviews.filter(\.passed).count, 1)
        },
        Achievement(id: "notes-5", title: "Note Taker", detail: "Write notes on 5 problems", icon: "note.text", color: Palette.yellow.color) {
            ($0.notes.count, 5)
        },
    ]

    static func unlockedIDs(_ store: ProgressStore) -> Set<String> {
        Set(all.filter { $0.isUnlocked(store) }.map(\.id))
    }
}

// MARK: - Badge grid

struct AchievementBadge: View {
    @Environment(ProgressStore.self) private var store
    let achievement: Achievement

    var body: some View {
        let unlocked = achievement.isUnlocked(store)
        let (current, target) = achievement.progress(store)
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(unlocked ? AnyShapeStyle(achievement.color.oklchGradient) : AnyShapeStyle(Color.primary.opacity(0.06)))
                    .frame(width: 52, height: 52)
                if !unlocked {
                    ProgressRing(progress: Double(current) / Double(max(target, 1)), lineWidth: 3,
                                 fill: AnyShapeStyle(achievement.color.opacity(0.7)))
                        .frame(width: 52, height: 52)
                }
                if unlocked {
                    Circle()
                        .strokeBorder(.white.opacity(0.3), lineWidth: 0.75)
                        .frame(width: 52, height: 52)
                        .blendMode(.plusLighter)
                }
                Image(systemName: achievement.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(unlocked ? .white : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            Text(achievement.title)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(unlocked ? "Unlocked" : "\(current)/\(target)")
                .font(.system(size: 9).monospacedDigit())
                .foregroundStyle(unlocked ? achievement.color : .secondary)
        }
        .frame(maxWidth: .infinity)
        .opacity(unlocked ? 1 : 0.75)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(achievement.title). \(achievement.detail). \(unlocked ? "Unlocked" : "\(current) of \(target)")")
    }
}

struct AchievementsCard: View {
    @Environment(ProgressStore.self) private var store
    @Environment(\.dynamicTypeSize) private var dynamicType
    @State private var selected: Achievement.ID?

    var body: some View {
        let unlocked = Achievements.unlockedIDs(store)
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader("Achievements", icon: "trophy.fill")
                Text("\(unlocked.count)/\(Achievements.all.count)")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.secondary)
                    .fixedSize()
            }
            // Columns follow the available width and text size rather than a fixed count.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: dynamicType.isAccessibilitySize ? 110 : 72), spacing: 8)], spacing: 14) {
                ForEach(Achievements.all) { achievement in
                    AchievementBadge(achievement: achievement)
                        .onTapGesture {
                            withAnimation(.snappy) { selected = selected == achievement.id ? nil : achievement.id }
                        }
                }
            }
            if let id = selected, let achievement = Achievements.all.first(where: { $0.id == id }) {
                Label(achievement.detail, systemImage: achievement.icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(achievement.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(achievement.color.opacity(0.1), in: .rounded(Radius.control))
                    .overlay(RoundedRectangle(cornerRadius: Radius.control, style: .continuous).strokeBorder(achievement.color.opacity(0.25), lineWidth: 0.75))
                    .id(achievement.id)
                    .transition(.blurReplace)
            }
        }
        .card()
    }
}

// MARK: - Unlock toast

private struct AchievementToastModifier: ViewModifier {
    @Environment(ProgressStore.self) private var store
    @AppStorage("achievements.seen") private var seenRaw = ""
    @AppStorage("achievements.seeded") private var seeded = false
    @State private var toast: Achievement?

    func body(content: Content) -> some View {
        let unlocked = Achievements.unlockedIDs(store)
        content
            .overlay(alignment: .top) {
                if let toast {
                    HStack(spacing: 12) {
                        Image(systemName: toast.icon)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(toast.color.oklchGradient, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 0.5).blendMode(.plusLighter))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ACHIEVEMENT UNLOCKED")
                                .font(.caption2.weight(.bold))
                                .tracking(0.8)
                                .foregroundStyle(toast.color)
                            Text(toast.title).font(.subheadline.weight(.bold))
                            Text(toast.detail).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    // Circular 40pt icon at 12pt inset: outer radius = 20 + 12, perfectly concentric.
                    .background(.regularMaterial, in: .rounded(Radius.outer(inner: 20, padding: 12)))
                    .overlay(RoundedRectangle(cornerRadius: Radius.outer(inner: 20, padding: 12), style: .continuous)
                        .strokeBorder(Theme.stroke, lineWidth: 0.75))
                    .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { withAnimation(.snappy) { self.toast = nil } }
                }
            }
            .onAppear {
                guard !seeded else { return }
                seenRaw = unlocked.sorted().joined(separator: ",")
                seeded = true
            }
            .onChange(of: unlocked) { _, new in
                var seen = Set(seenRaw.split(separator: ",").map(String.init))
                let fresh = Achievements.all.filter { new.contains($0.id) && !seen.contains($0.id) }
                guard let first = fresh.first else { return }
                seen.formUnion(fresh.map(\.id))
                seenRaw = seen.sorted().joined(separator: ",")
                withAnimation(.spring(duration: 0.5)) { toast = first }
                Task {
                    try? await Task.sleep(for: .seconds(3.5))
                    withAnimation(.snappy) { if toast?.id == first.id { toast = nil } }
                }
            }
            .sensoryFeedback(.success, trigger: toast?.id) { _, new in new != nil }
    }
}

extension View {
    func achievementToasts() -> some View { modifier(AchievementToastModifier()) }
}
