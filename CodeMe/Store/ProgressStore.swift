import Foundation
import Observation

/// Persists the learner's progress (solved problems, stars, code drafts) in UserDefaults.
@Observable
final class ProgressStore {
    private(set) var solved: [String: Date] = [:]
    private(set) var starred: Set<String> = []
    private(set) var drafts: [String: String] = [:]
    private(set) var bestQuizStreak: Int = 0

    @ObservationIgnored private let defaults: UserDefaults

    private enum Key {
        static let solved = "progress.solved"
        static let starred = "progress.starred"
        static let drafts = "progress.drafts"
        static let quiz = "progress.bestQuizStreak"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        solved = Self.load([String: Date].self, from: defaults, key: Key.solved) ?? [:]
        starred = Self.load(Set<String>.self, from: defaults, key: Key.starred) ?? []
        drafts = Self.load([String: String].self, from: defaults, key: Key.drafts) ?? [:]
        bestQuizStreak = defaults.integer(forKey: Key.quiz)
    }

    // MARK: Solved

    func isSolved(_ problem: Problem) -> Bool { solved[problem.id] != nil }

    func toggleSolved(_ problem: Problem) {
        solved[problem.id] = isSolved(problem) ? nil : Date()
        save(solved, key: Key.solved)
    }

    var solvedCount: Int { ProblemBank.all.filter(isSolved).count }

    func solvedCount(in topic: Topic) -> Int {
        ProblemBank.problems(for: topic).filter(isSolved).count
    }

    func solvedCount(_ difficulty: Difficulty) -> Int {
        ProblemBank.all.filter { $0.difficulty == difficulty && isSolved($0) }.count
    }

    var completedTopics: Int {
        Topic.allCases.filter { solvedCount(in: $0) == ProblemBank.problems(for: $0).count }.count
    }

    /// First unsolved problem in roadmap order.
    var nextProblem: Problem? { ProblemBank.all.first { !isSolved($0) } }

    // MARK: Activity

    /// Number of problems solved per calendar day.
    var activityByDay: [Date: Int] {
        let calendar = Calendar.current
        return solved.values.reduce(into: [:]) { counts, date in
            counts[calendar.startOfDay(for: date), default: 0] += 1
        }
    }

    var activeDays: Int { activityByDay.count }

    /// Consecutive days (ending today or yesterday) with at least one solve.
    var currentStreak: Int {
        let calendar = Calendar.current
        let days = Set(activityByDay.keys)
        var day = calendar.startOfDay(for: Date())
        if !days.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        var streak = 0
        while days.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    // MARK: Stars

    func isStarred(_ problem: Problem) -> Bool { starred.contains(problem.id) }

    func toggleStar(_ problem: Problem) {
        if starred.contains(problem.id) { starred.remove(problem.id) } else { starred.insert(problem.id) }
        save(starred, key: Key.starred)
    }

    // MARK: Drafts

    func draft(for problem: Problem) -> String { drafts[problem.id] ?? problem.starterCode }

    func saveDraft(_ code: String, for problem: Problem) {
        guard drafts[problem.id] != code else { return }
        drafts[problem.id] = code
        save(drafts, key: Key.drafts)
    }

    func resetDraft(for problem: Problem) {
        drafts[problem.id] = nil
        save(drafts, key: Key.drafts)
    }

    // MARK: Quiz

    func recordQuizStreak(_ streak: Int) {
        guard streak > bestQuizStreak else { return }
        bestQuizStreak = streak
        defaults.set(streak, forKey: Key.quiz)
    }

    // MARK: Reset

    func resetAll() {
        solved = [:]
        starred = []
        drafts = [:]
        bestQuizStreak = 0
        for key in [Key.solved, Key.starred, Key.drafts, Key.quiz] {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: Persistence

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
