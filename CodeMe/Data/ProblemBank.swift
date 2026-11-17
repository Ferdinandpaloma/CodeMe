import Foundation

enum ProblemBank {
    /// Every problem, ordered by roadmap topic.
    static let all: [Problem] = {
        let combined = arrays + twoPointers + slidingWindow + stack
            + binarySearch + linkedList + trees + tries
            + heap + backtracking + graphs + advancedGraphs
            + dp1d + dp2d + greedy + intervals + math + bits
        return Topic.allCases.flatMap { topic in combined.filter { $0.topic == topic } }
    }()

    static let byTopic: [Topic: [Problem]] = Dictionary(grouping: all, by: \.topic)
    static let byID: [String: Problem] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func problems(for topic: Topic) -> [Problem] { byTopic[topic] ?? [] }

    static func ex(_ input: String, _ output: String, _ explanation: String? = nil) -> Example {
        Example(input: input, output: output, explanation: explanation)
    }

    static let listNodeHeader = """
    # Definition for singly-linked list.
    # class ListNode:
    #     def __init__(self, val=0, next=None):
    #         self.val = val
    #         self.next = next

    """

    static let treeNodeHeader = """
    # Definition for a binary tree node.
    # class TreeNode:
    #     def __init__(self, val=0, left=None, right=None):
    #         self.val = val
    #         self.left = left
    #         self.right = right

    """
}
