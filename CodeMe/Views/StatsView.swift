import SwiftUI

struct StatsView: View {
    @Environment(ProgressStore.self) private var store
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    overviewCard
                    HStack(spacing: 10) {
                        StatTile(icon: "flame.fill", value: "\(store.currentStreak)", label: "Day streak", color: .orange)
                        StatTile(icon: "calendar", value: "\(store.activeDays)", label: "Active days", color: Theme.accent2)
                        StatTile(icon: "star.fill", value: "\(store.starred.count)", label: "Starred", color: .yellow)
                    }
                    activityCard
                    topicsCard
                    Button(role: .destructive) {
                        confirmReset = true
                    } label: {
                        Label("Reset Progress", systemImage: "trash")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .foregroundStyle(Theme.hard)
                    .card(padding: 0)
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Progress")
            .appDestinations()
            .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset Everything", role: .destructive) {
                    withAnimation { store.resetAll() }
                }
            } message: {
                Text("This clears solved problems, stars, saved code and your quiz record.")
            }
        }
    }

    private var overviewCard: some View {
        let total = ProblemBank.all.count
        let solved = store.solvedCount

        return HStack(spacing: 20) {
            ZStack {
                ProgressRing(progress: total == 0 ? 0 : Double(solved) / Double(total), lineWidth: 12)
                VStack(spacing: 0) {
                    Text("\(solved)")
                        .font(.title.weight(.bold).monospacedDigit())
                        .contentTransition(.numericText())
                    Text("of \(total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 112, height: 112)

            VStack(spacing: 12) {
                ForEach(Difficulty.allCases) { level in
                    let levelTotal = ProblemBank.all.filter { $0.difficulty == level }.count
                    let levelSolved = store.solvedCount(level)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(level.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(level.color)
                            Spacer()
                            Text("\(levelSolved)/\(levelTotal)")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        ProgressBar(progress: levelTotal == 0 ? 0 : Double(levelSolved) / Double(levelTotal), color: level.color)
                    }
                }
            }
        }
        .card(padding: 20)
    }

    private var activityCard: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weeks = 16
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let start = calendar.date(byAdding: .weekOfYear, value: -(weeks - 1), to: thisWeekStart) ?? today
        let activity = store.activityByDay

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader("Activity", icon: "square.grid.4x3.fill")
                Spacer()
                HStack(spacing: 3) {
                    Text("Less").font(.caption2).foregroundStyle(.secondary)
                    ForEach(0..<4, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 3).fill(cellColor(level)).frame(width: 10, height: 10)
                    }
                    Text("More").font(.caption2).foregroundStyle(.secondary)
                }
                .fixedSize()
            }
            HStack(spacing: 4) {
                ForEach(0..<weeks, id: \.self) { week in
                    VStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let day = calendar.date(byAdding: .day, value: week * 7 + weekday, to: start) ?? today
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(day > today ? Color.clear : cellColor(activity[day] ?? 0))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .card()
    }

    private func cellColor(_ count: Int) -> Color {
        switch count {
        case 0: Color.primary.opacity(0.07)
        case 1: Theme.accent.opacity(0.4)
        case 2: Theme.accent.opacity(0.7)
        default: Theme.accent
        }
    }

    private var topicsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Topic mastery", icon: "square.stack.3d.up")
            ForEach(Topic.allCases) { topic in
                let total = ProblemBank.problems(for: topic).count
                let done = store.solvedCount(in: topic)
                NavigationLink(value: topic) {
                    HStack(spacing: 12) {
                        TopicIcon(topic: topic, size: 30)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(topic.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(done)/\(total)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            ProgressBar(progress: total == 0 ? 0 : Double(done) / Double(total), color: topic.color, height: 5)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .card()
    }
}

private struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .card(padding: 14)
    }
}
