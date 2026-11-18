import SwiftUI

struct LessonSection: Hashable {
    let heading: String
    let body: String
    var code: String? = nil
}

struct QuizQuestion: Hashable {
    let prompt: String
    let options: [String]
    let answer: Int
    let explanation: String
}

struct Lesson: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let sections: [LessonSection]
    let quiz: [QuizQuestion]

    var minutes: Int { max(2, sections.count + quiz.count / 2) }

    static func == (lhs: Lesson, rhs: Lesson) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Topic {
    var lesson: Lesson { LessonBank.lesson(for: self) }
}

extension Problem {
    /// One-line takeaway to remember the trick behind the problem.
    var insight: String? { ProblemBank.insights[id] ?? ProblemBank.extraInsights[id] }
}
