import SwiftUI

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: Self { self }

    var color: Color {
        switch self {
        case .easy: Theme.easy
        case .medium: Theme.medium
        case .hard: Theme.hard
        }
    }
}

struct Example: Hashable {
    let input: String
    let output: String
    var explanation: String? = nil
}

struct Problem: Identifiable, Hashable {
    /// LeetCode slug, e.g. "two-sum".
    let id: String
    let number: Int
    let title: String
    let difficulty: Difficulty
    let topic: Topic
    let description: String
    let examples: [Example]
    let constraints: [String]
    let hints: [String]
    let approach: [String]
    let solution: String
    let time: String
    let space: String
    var starterOverride: String? = nil

    var starterCode: String { starterOverride ?? StarterCode.derive(from: solution) }
    var leetCodeURL: URL { URL(string: "https://leetcode.com/problems/\(id)/")! }

    static func == (lhs: Problem, rhs: Problem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum StarterCode {
    /// Builds a starter template from a full solution by keeping top-level comments,
    /// class declarations and method signatures, replacing every body with `pass`.
    static func derive(from solution: String) -> String {
        var out: [String] = []
        for line in solution.components(separatedBy: "\n") {
            let indent = line.prefix { $0 == " " }.count
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if indent == 0 && (trimmed.hasPrefix("#") || trimmed.hasPrefix("class ")) {
                if trimmed.hasPrefix("class "), let last = out.last, last.hasSuffix("pass") {
                    out.append("")
                }
                out.append(line)
            } else if indent == 4 && trimmed.hasPrefix("def ") {
                if let last = out.last, last.hasSuffix("pass") { out.append("") }
                out.append(line)
                out.append("        pass")
            }
        }
        return out.joined(separator: "\n") + "\n"
    }
}
