import Foundation
import Observation

struct ReviewState: Codable, Equatable {
    var interval: Int   // days
    var due: Date
    var reps: Int
}

enum ReviewGrade: CaseIterable, Identifiable {
    case again, hard, good, easy
    var id: Self { self }

    var label: String {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }

    func nextInterval(from interval: Int) -> Int {
        switch self {
        case .again: 1
        case .hard: max(1, Int((Double(interval) * 1.2).rounded()))
        case .good: max(interval + 1, Int((Double(interval) * 2.5).rounded()))
        case .easy: max(interval + 2, interval * 4)
        }
    }
}

struct InterviewRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    let date: Date
    let problemIDs: [String]
    let solvedIDs: [String]
    let seconds: Int
    let limitSeconds: Int
    let hintsUsed: Int

    var problems: [Problem] { problemIDs.compactMap { ProblemBank.byID[$0] } }
    var passed: Bool { solvedIDs.count == problemIDs.count && seconds <= limitSeconds }
}

/// Persists the learner's progress (solved problems, stars, code drafts) in UserDefaults.
@Observable
final class ProgressStore {
    private(set) var solved: [String: Date] = [:]
    private(set) var starred: Set<String> = []
    private(set) var drafts: [String: String] = [:]
    private(set) var bestQuizStreak: Int = 0
    private(set) var reviews: [String: ReviewState] = [:]
    private(set) var completedLessons: Set<String> = []
    private(set) var notes: [String: String] = [:]
    private(set) var interviews: [InterviewRecord] = []
    private(set) var drillCorrect: Int = 0

    @ObservationIgnored private let defaults: UserDefaults

    private enum Key {
        static let solved = "progress.solved"
        static let starred = "progress.starred"
        static let drafts = "progress.drafts"
        static let quiz = "progress.bestQuizStreak"
        static let reviews = "progress.reviews"
        static let lessons = "progress.lessons"
        static let notes = "progress.notes"
        static let interviews = "progress.interviews"
        static let drills = "progress.drillCorrect"
        static let all = [solved, starred, drafts, quiz, reviews, lessons, notes, interviews, drills]
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        solved = Self.load([String: Date].self, from: defaults, key: Key.solved) ?? [:]
        starred = Self.load(Set<String>.self, from: defaults, key: Key.starred) ?? []
        drafts = Self.load([String: String].self, from: defaults, key: Key.drafts) ?? [:]
        bestQuizStreak = defaults.integer(forKey: Key.quiz)
        reviews = Self.load([String: ReviewState].self, from: defaults, key: Key.reviews) ?? [:]
        completedLessons = Self.load(Set<String>.self, from: defaults, key: Key.lessons) ?? []
        notes = Self.load([String: String].self, from: defaults, key: Key.notes) ?? [:]
        interviews = Self.load([InterviewRecord].self, from: defaults, key: Key.interviews) ?? []
        drillCorrect = defaults.integer(forKey: Key.drills)

        // Problems solved before reviews existed join the review deck.
        var backfilled = false
        for (id, date) in solved where reviews[id] == nil {
            reviews[id] = ReviewState(interval: 1, due: Self.addDays(1, to: date), reps: 0)
            backfilled = true
        }
        if backfilled { save(reviews, key: Key.reviews) }
    }

    // MARK: Solved

    func isSolved(_ problem: Problem) -> Bool { solved[problem.id] != nil }

    func toggleSolved(_ problem: Problem) {
        if isSolved(problem) {
            solved[problem.id] = nil
            reviews[problem.id] = nil
        } else {
            solved[problem.id] = Date()
            reviews[problem.id] = ReviewState(interval: 1, due: Self.addDays(1, to: Date()), reps: 0)
        }
        save(solved, key: Key.solved)
        save(reviews, key: Key.reviews)
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

    // MARK: Spaced repetition

    var dueReviews: [Problem] {
        let now = Date()
        return ProblemBank.all
            .filter { reviews[$0.id].map { $0.due <= now } ?? false }
            .sorted { reviews[$0.id]!.due < reviews[$1.id]!.due }
    }

    var nextReviewDate: Date? {
        let now = Date()
        return reviews.values.map(\.due).filter { $0 > now }.min()
    }

    func interval(for problem: Problem, grade: ReviewGrade) -> Int {
        grade.nextInterval(from: reviews[problem.id]?.interval ?? 1)
    }

    func review(_ problem: Problem, grade: ReviewGrade) {
        var state = reviews[problem.id] ?? ReviewState(interval: 1, due: Date(), reps: 0)
        state.interval = grade.nextInterval(from: state.interval)
        state.due = Self.addDays(state.interval, to: Calendar.current.startOfDay(for: Date()))
        state.reps += 1
        reviews[problem.id] = state
        save(reviews, key: Key.reviews)
    }

    private static func addDays(_ days: Int, to date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Calendar.current.startOfDay(for: date)) ?? date
    }

    // MARK: Lessons

    func isComplete(_ lesson: Lesson) -> Bool { completedLessons.contains(lesson.id) }

    func completeLesson(_ lesson: Lesson) {
        guard !completedLessons.contains(lesson.id) else { return }
        completedLessons.insert(lesson.id)
        save(completedLessons, key: Key.lessons)
    }

    // MARK: Daily

    /// Problems solved today.
    var solvedToday: Int { activityByDay[Calendar.current.startOfDay(for: Date())] ?? 0 }

    /// Total review sessions graded across all problems.
    var totalReviews: Int { reviews.values.reduce(0) { $0 + $1.reps } }

    /// A problem chosen per calendar day, preferring unsolved ones.
    /// Problems solved today still qualify, so the pick stays put after you solve it.
    var problemOfTheDay: Problem {
        let all = ProblemBank.all
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        // Multiplicative hash spreads consecutive days across topics.
        let start = ((day &* 2_654_435_761) & 0x7FFF_FFFF) % all.count
        let today = Calendar.current.startOfDay(for: Date())
        for offset in 0..<all.count {
            let problem = all[(start + offset) % all.count]
            guard let date = solved[problem.id] else { return problem }
            if date >= today { return problem }
        }
        return all[start]
    }

    // MARK: Notes

    func note(for problem: Problem) -> String { notes[problem.id] ?? "" }

    func saveNote(_ text: String, for problem: Problem) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        notes[problem.id] = trimmed.isEmpty ? nil : text
        save(notes, key: Key.notes)
    }

    // MARK: Interviews

    func recordInterview(_ record: InterviewRecord) {
        interviews.insert(record, at: 0)
        save(interviews, key: Key.interviews)
    }

    // MARK: Code drills

    func recordDrillCorrect() {
        drillCorrect += 1
        defaults.set(drillCorrect, forKey: Key.drills)
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
        reviews = [:]
        completedLessons = []
        notes = [:]
        interviews = []
        drillCorrect = 0
        for key in Key.all {
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
