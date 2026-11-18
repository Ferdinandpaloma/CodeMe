import SwiftUI

enum LessonBank {
    static let fundamentals: [Lesson] = [bigO, pythonToolkit]
    static let all: [Lesson] = fundamentals + Topic.allCases.map(\.lesson)

    private static let topicLessons: [Topic: Lesson] = Dictionary(
        uniqueKeysWithValues: Topic.allCases.map { ($0, makeTopicLesson($0)) }
    )

    static func lesson(for topic: Topic) -> Lesson { topicLessons[topic]! }

    private static func q(_ prompt: String, _ options: [String], _ answer: Int, _ explanation: String) -> QuizQuestion {
        QuizQuestion(prompt: prompt, options: options, answer: answer, explanation: explanation)
    }

    // MARK: - Fundamentals

    static let bigO = Lesson(
        id: "fundamentals.big-o", title: "Big-O Notation", subtitle: "How to measure and compare solutions",
        icon: "speedometer", color: Color(hex: 0xF472B6),
        sections: [
            LessonSection(heading: "What Big-O measures", body: "Big-O describes how an algorithm's running time (or memory) **grows** as the input size `n` grows. Constants and smaller terms are dropped: `3n + 10` becomes **O(n)**.\n\nInterviewers care about growth because a solution that's fine for 100 items can time out at 100,000."),
            LessonSection(heading: "The common classes", body: "From fastest to slowest:\n\n• **O(1)**: hash lookup, array index\n• **O(log n)**: binary search, halving every step\n• **O(n)**: one pass over the input\n• **O(n log n)**: sorting\n• **O(n²)**: nested loops over the input\n• **O(2ⁿ)**: every subset\n• **O(n!)**: every permutation"),
            LessonSection(heading: "Reading code", body: "Count how many times the innermost work runs. Sequential blocks **add**, and nested loops **multiply**. Keep only the biggest term.", code: #"""
                for x in nums:          # n times
                    for y in nums:      # × n times
                        check(x, y)     # → O(n²)

                nums.sort()             # O(n log n)
                for x in nums:          # + O(n)
                    seen.add(x)         # → O(n log n) overall
                """#),
            LessonSection(heading: "Space complexity", body: "Count the **extra** memory you allocate: a set holding n items is O(n) space.\n\nRecursion uses the call stack too: a DFS on a tree of height h takes **O(h)** space. The input itself usually doesn't count."),
            LessonSection(heading: "Constraints are hints", body: "Computers do roughly 10⁸ simple operations per second, so the constraints reveal the target complexity:\n\n• n ≤ 20 → O(2ⁿ) backtracking is fine\n• n ≤ 10³ → O(n²) works\n• n ≤ 10⁵ → aim for O(n log n) or O(n)\n• n ≤ 10⁹ → you need O(log n) or O(1)"),
        ],
        quiz: [
            q("A loop over n items does a binary search on each iteration. Time complexity?", ["O(n)", "O(log n)", "O(n log n)", "O(n²)"], 2, "n iterations × O(log n) each = O(n log n)."),
            q("The constraints say n ≤ 10⁵. Which approach is likely too slow?", ["O(n)", "O(n log n)", "O(n²)", "O(log n)"], 2, "(10⁵)² = 10¹⁰ operations, far beyond a typical time limit."),
            q("A recursive DFS on a balanced binary tree with n nodes uses how much stack space?", ["O(1)", "O(log n)", "O(n)", "O(n²)"], 1, "A balanced tree has height log n, and the call stack only holds one root-to-leaf path at a time."),
        ]
    )

    static let pythonToolkit = Lesson(
        id: "fundamentals.python", title: "Python for Interviews", subtitle: "The built-ins you'll use every day",
        icon: "chevron.left.forwardslash.chevron.right", color: Color(hex: 0xFFCB6B),
        sections: [
            LessonSection(heading: "Hash maps & sets", body: "`dict` and `set` give O(1) average lookups. The `collections` module adds two shortcuts you'll use constantly.", code: #"""
                seen = set()
                seen.add(3)
                print(3 in seen)              # O(1)

                count = {}
                count[x] = count.get(x, 0) + 1

                from collections import defaultdict, Counter
                groups = defaultdict(list)    # missing keys start as []
                freq = Counter("banana")      # {'a': 3, 'n': 2, 'b': 1}
                freq.most_common(2)           # [('a', 3), ('n', 2)]
                """#),
            LessonSection(heading: "Stacks & queues", body: "A `list` is a stack: `append` and `pop` at the end are O(1). For a queue, use `deque`, because `list.pop(0)` is **O(n)**.", code: #"""
                stack = []
                stack.append(1)
                top = stack[-1]
                stack.pop()

                from collections import deque
                queue = deque([start])
                queue.append(x)
                first = queue.popleft()       # O(1)
                """#),
            LessonSection(heading: "Heaps", body: "`heapq` turns a plain list into a **min-heap**. For a max-heap, push negated values. Tuples compare element by element, which is perfect for `(priority, item)`.", code: #"""
                import heapq
                heap = []
                heapq.heappush(heap, 5)
                smallest = heapq.heappop(heap)
                heapq.heapify(nums)           # O(n)

                heapq.heappush(heap, -x)      # max-heap trick
                heapq.heappush(heap, (dist, node))
                """#),
            LessonSection(heading: "Sorting & searching", body: "Python's sort is O(n log n) and stable. `key=` controls what to compare, and `bisect` gives binary search for free.", code: #"""
                nums.sort()                           # in place
                pairs.sort(key=lambda p: p[1])        # by second item
                sorted(words, key=len, reverse=True)  # new list

                from bisect import bisect_left
                i = bisect_left(nums, target)         # first index >= target
                """#),
            LessonSection(heading: "Handy idioms", body: "Small idioms that keep interview code short and correct.", code: #"""
                for i, x in enumerate(nums): ...
                for a, b in zip(xs, ys): ...

                grid = [[0] * cols for _ in range(rows)]  # not [[0] * cols] * rows!
                s[::-1]                  # reversed copy
                float("inf")             # start value for min tracking
                ord(c) - ord("a")        # letter -> 0..25
                """#),
        ],
        quiz: [
            q("Which operation is O(n) and should be avoided in a BFS loop?", ["deque.popleft()", "list.pop()", "list.pop(0)", "set.add(x)"], 2, "Removing from the front of a list shifts every remaining element. Use `deque.popleft()`."),
            q("How do you get a max-heap with heapq?", ["heapq.maxheap()", "Push negated values", "Pass reverse=True", "Sort after every push"], 1, "heapq only provides a min-heap, and negating the keys flips the order."),
            q("Why is `[[0] * 3] * 3` a bug?", ["It creates a 3×1 grid", "All three rows are the same list object", "It runs in O(n³)", "It raises a TypeError"], 1, "Multiplying the outer list copies the reference, so editing one row edits all three."),
        ]
    )

    // MARK: - Topic lessons

    private static func makeTopicLesson(_ topic: Topic) -> Lesson {
        let (sections, quiz) = content(for: topic)
        return Lesson(
            id: "topic.\(topic.rawValue)", title: topic.name, subtitle: topic.summary,
            icon: topic.icon, color: topic.color, sections: sections, quiz: quiz
        )
    }

    private static func content(for topic: Topic) -> ([LessonSection], [QuizQuestion]) {
        switch topic {
        case .arrays:
            return ([
                LessonSection(heading: "Why hashing?", body: "Many brute-force solutions compare every pair, which is **O(n²)**. A hash set or map remembers what you've seen, so each \"have I seen X?\" check is **O(1)**, giving O(n) overall.\n\nThe trade-off: O(n) extra memory."),
                LessonSection(heading: "Three core moves", body: "• **Membership**: a set of seen values (duplicates)\n• **Complement lookup**: a map from value → index (Two Sum)\n• **Grouping / counting**: a map from key → list or count (anagrams, frequencies)", code: #"""
                    seen = set()                 # membership
                    index = {}                   # value -> index
                    groups = defaultdict(list)   # key -> items
                    count = Counter(nums)        # value -> frequency
                    """#),
                LessonSection(heading: "Choosing the key", body: "The hardest part is designing a key that's identical for items that belong together. Anagrams share sorted letters or letter counts.\n\n**Watch out:** keys must be immutable, so use `tuple(lst)` rather than a `list`."),
            ], [
                q("Check whether an array has duplicates in O(n). What do you use?", ["Sort and compare neighbors", "A hash set", "Two nested loops", "Binary search"], 1, "A set gives O(1) membership checks. Sorting also works but costs O(n log n)."),
                q("Which can be a dictionary key for grouping anagrams?", ["A list of 26 counts", "A tuple of 26 counts", "A set of letters", "A Counter"], 1, "Keys must be hashable: tuples are, but lists, sets and Counters aren't. A set would also lose the counts."),
            ])
        case .twoPointers:
            return ([
                LessonSection(heading: "The idea", body: "Use two indices that move toward each other (or in the same direction). Each comparison tells you which pointer to move, so you scan in a single **O(n)** pass instead of checking every pair."),
                LessonSection(heading: "Opposite ends", body: "On sorted input, if the sum is too small, only moving `l` right can increase it. If it's too big, move `r` left. Every move rules out a whole set of pairs at once.", code: topic.template),
                LessonSection(heading: "Watch out", body: "• Sort first when order doesn't matter (3Sum).\n• Skip equal neighbors to avoid duplicate answers.\n• Use `l < r`, not `l <= r`, when you need two distinct elements."),
            ], [
                q("Sorted array, looking for a pair that sums to target. The current sum is too large. What do you do?", ["Move l right", "Move r left", "Move both", "Restart"], 1, "Moving r left picks a smaller value, which lowers the sum."),
                q("Why does 3Sum sort the array first?", ["Python requires it", "It enables two pointers and easy duplicate skipping", "It makes the whole thing O(n)", "To find the median"], 1, "Sorted order lets the pointers know which way to move, and puts duplicates next to each other."),
            ])
        case .slidingWindow:
            return ([
                LessonSection(heading: "Contiguous ranges", body: "When a problem asks for the best **contiguous** subarray or substring, keep a window `[l, r]`. Expand `r` every step, and shrink `l` only when the window breaks a rule. Each index enters and leaves once, so the scan is **O(n)**."),
                LessonSection(heading: "The template", body: "Update the window's state incrementally (counts in a map, a set of characters) instead of recomputing it from scratch.", code: topic.template),
                LessonSection(heading: "Variable vs fixed size", body: "• **Variable**: grow until invalid, then shrink (longest substring without repeats).\n• **Fixed size k**: add `nums[r]` and remove `nums[r - k]`.\n• For a **minimum** window, shrink while the window is still valid and record the answer as you go."),
            ], [
                q("Why is a sliding window O(n) even with a while loop inside the for loop?", ["The while loop runs once", "l and r each move forward at most n times in total", "It's actually O(n²)", "Python optimizes it"], 1, "The pointers never move backward, so the total work is at most 2n steps."),
                q("Which problem fits a sliding window?", ["Longest substring with at most k distinct characters", "Number of islands", "Kth largest element", "Merge two sorted lists"], 0, "Best contiguous substring under a constraint is the classic window signal."),
            ])
        case .stack:
            return ([
                LessonSection(heading: "Last in, first out", body: "A stack gives O(1) access to the **most recent** item. That fits anything nested (brackets, function calls, undo) and anything where a new item resolves older pending ones."),
                LessonSection(heading: "Monotonic stack", body: "Keep the stack sorted, for example decreasing. When a new value breaks the order, pop everything it beats: the new value is their **next greater element**. Each index is pushed and popped once, so it's O(n).", code: topic.template),
                LessonSection(heading: "Watch out", body: "• Check `if stack` before using `stack[-1]` or `pop()`.\n• Store **indices**, not values, when you need distances.\n• Whatever remains on the stack at the end never found an answer."),
            ], [
                q("Daily Temperatures asks how many days until a warmer day. What goes on the stack?", ["Temperatures", "Indices", "Answers", "Nothing, use a queue"], 1, "Indices let you compute `i - j` and still look up the temperature."),
                q("Valid Parentheses: you read `)` and the top of the stack is `[`. Result?", ["Push it", "Pop and continue", "Return False", "Ignore it"], 2, "The most recent opener must match the closer, and `[` doesn't match `)`."),
            ])
        case .binarySearch:
            return ([
                LessonSection(heading: "Halve the space", body: "Each comparison discards half of the candidates, so n items take only about **log₂ n** steps. A million items need around 20 checks."),
                LessonSection(heading: "Search the answer", body: "Binary search isn't only for sorted arrays. If you can ask \"does value k work?\" and the answers look like `F F F T T T`, binary search for the first `T`. Koko Eating Bananas searches over eating speeds.", code: topic.template),
                LessonSection(heading: "Avoid off-by-one bugs", body: "• `while l <= r` with `l = mid + 1` / `r = mid - 1` finds an exact match.\n• `while l < r` with `r = mid` finds a boundary (the first True).\n• Make sure every branch shrinks the range, or the loop never ends."),
            ], [
                q("Roughly how many steps does it take to binary search 1,000,000 sorted items?", ["20", "1,000", "500,000", "1,000,000"], 0, "2²⁰ ≈ 1,000,000, so about 20 halvings."),
                q("Koko Eating Bananas binary searches over…", ["The piles array", "Possible eating speeds", "The hours", "Pile indices"], 1, "Feasibility is monotonic in speed: if k works, any faster speed also works."),
            ])
        case .linkedList:
            return ([
                LessonSection(heading: "Nodes and pointers", body: "A linked list is a chain of nodes, each holding `val` and `next`. There's no random access, but you can insert or remove a node in O(1) once you hold a reference. Most problems test careful pointer rewiring."),
                LessonSection(heading: "Key techniques", body: "• **Dummy head** avoids special cases for the first node.\n• **Reverse in place** with `prev`, `curr` and a saved `next`.\n• **Fast/slow pointers** find the middle or detect cycles.", code: topic.template),
                LessonSection(heading: "Watch out", body: "Save `curr.next` **before** overwriting it, or you lose the rest of the list. Check `fast and fast.next` before jumping two steps."),
            ], [
                q("How does Floyd's algorithm detect a cycle?", ["Count the nodes", "A fast pointer eventually meets the slow one", "Store every value in a set", "Reverse the list"], 1, "Inside a loop the fast runner gains one node per step, so it must land on the slow runner."),
                q("Why use a dummy node when merging lists?", ["It's faster", "It removes the special case for picking the head", "It saves memory", "Python requires it"], 1, "You always append to `tail.next` and return `dummy.next` at the end."),
            ])
        case .trees:
            return ([
                LessonSection(heading: "Think recursively", body: "A tree is a node plus two smaller trees. Most tree solutions come down to one question: **what should each subtree return to its parent?** Then combine the left and right answers at the node."),
                LessonSection(heading: "DFS vs BFS", body: "• **DFS** (recursion) for depth, paths and validation. Uses O(h) stack space.\n• **BFS** (a queue) for level-by-level questions and the fewest steps.", code: topic.template),
                LessonSection(heading: "The BST property", body: "In a binary search tree, everything in the left subtree is smaller and everything in the right subtree is larger. An in-order traversal visits values in sorted order.\n\nTo validate a BST, pass `(low, high)` bounds down the tree. Comparing a node only with its direct children isn't enough."),
            ], [
                q("Which traversal lists values level by level?", ["Pre-order DFS", "In-order DFS", "BFS with a queue", "Post-order DFS"], 2, "BFS processes the queue one level at a time."),
                q("An in-order traversal of a valid BST produces values in what order?", ["Random", "Sorted ascending", "Sorted descending", "Level order"], 1, "Left subtree, then the node, then the right subtree gives sorted order."),
            ])
        case .tries:
            return ([
                LessonSection(heading: "Prefix trees", body: "A trie stores strings character by character, so words with a common prefix share a path. Looking up a word or prefix of length L takes **O(L)**, no matter how many words are stored."),
                LessonSection(heading: "Structure", body: "Each node holds a map of children and a flag marking whether a word ends there.", code: topic.template),
                LessonSection(heading: "When to use one", body: "Use a trie for prefix queries, autocomplete, wildcard search (`.` → try every child) and word-search grids with many words. For a single exact lookup, a hash set is simpler."),
            ], [
                q("Why does a trie node need an `is_end` flag?", ["To save memory", "To tell a complete word apart from a prefix", "To sort the children", "For deletion"], 1, "Without it, inserting \"apple\" would make search(\"app\") return true."),
                q("How long does it take to check whether a prefix of length L exists?", ["O(1)", "O(L)", "O(n · L)", "O(log n)"], 1, "You follow one child pointer per character."),
            ])
        case .heap:
            return ([
                LessonSection(heading: "Instant min (or max)", body: "A heap shows its smallest item in O(1), and push/pop take **O(log n)**. Reach for one whenever you repeatedly need the best item from a changing collection."),
                LessonSection(heading: "The top-k trick", body: "To keep the k **largest** items, use a **min-heap of size k**: when it overflows, pop the smallest. The top is then the k-th largest, in O(n log k) instead of sorting everything.", code: topic.template),
                LessonSection(heading: "Two heaps", body: "For a running median, keep a max-heap for the lower half and a min-heap for the upper half, balanced in size. The median sits at their tops."),
            ], [
                q("What's the most efficient way to keep the k largest elements of a stream?", ["A max-heap of all n items", "A min-heap of size k", "A sorted list", "A stack"], 1, "The min-heap evicts the smallest candidate, so the k largest remain. O(n log k)."),
                q("Python's heapq is a…", ["Max-heap", "Min-heap", "Balanced BST", "Either, configurable"], 1, "Negate values to simulate a max-heap."),
            ])
        case .backtracking:
            return ([
                LessonSection(heading: "Explore and undo", body: "Backtracking builds a candidate one choice at a time. After exploring a choice, **undo** it and try the next. It's a DFS over a decision tree, and it fits whenever you must list **all** valid answers."),
                LessonSection(heading: "Choose, explore, un-choose", body: "Record `path.copy()`. The list keeps changing, so appending `path` itself would store a reference that ends up empty.", code: topic.template),
                LessonSection(heading: "Duplicates & pruning", body: "• Pass a `start` index so the same combination isn't produced in a different order.\n• Sort and skip equal neighbors when the input has duplicates.\n• **Prune**: stop early when a branch can't succeed, such as when the remaining target goes negative."),
            ], [
                q("Why `result.append(path.copy())` instead of `result.append(path)`?", ["It's faster", "path keeps changing, so we need a snapshot", "copy() sorts the list", "There's no difference"], 1, "Otherwise every entry in result points to the same list."),
                q("How many subsets does a set of n elements have?", ["n", "n²", "2ⁿ", "n!"], 2, "Each element is either in or out, so 2 choices n times."),
            ])
        case .graphs:
            return ([
                LessonSection(heading: "Model it as a graph", body: "A graph is nodes plus edges, and a grid is a graph too: each cell connects to its 4 neighbors. Build an adjacency list with `defaultdict(list)` and always track **visited** nodes to avoid infinite loops."),
                LessonSection(heading: "BFS or DFS?", body: "• **DFS** for connectivity, counting components and flood fill.\n• **BFS** for shortest paths in unweighted graphs and for processes that spread outward (multi-source BFS).", code: topic.template),
                LessonSection(heading: "Topological sort", body: "For dependencies such as course prerequisites, repeatedly take nodes with in-degree 0 (**Kahn's algorithm**). If you can't process every node, the graph has a cycle."),
            ], [
                q("Fewest steps between two cells in an unweighted grid?", ["DFS", "BFS", "Dijkstra is required", "Binary search"], 1, "BFS explores in rings of increasing distance, so the first time it reaches a cell is the shortest path."),
                q("\"Can all courses be finished?\" is really asking whether…", ["The directed graph has a cycle", "There's a shortest path", "A spanning tree exists", "The graph is bipartite"], 0, "Circular prerequisites make finishing impossible."),
            ])
        case .dp1d:
            return ([
                LessonSection(heading: "Remember subproblems", body: "Dynamic programming is recursion with memory. If a brute-force recursion solves the same subproblem many times, store each answer once and reuse it. That turns exponential time into polynomial."),
                LessonSection(heading: "The recipe", body: "1. **State**: `dp[i]` = the answer for the first i items.\n2. **Recurrence**: how `dp[i]` uses smaller states.\n3. **Base cases**.\n4. **Order**: fill bottom-up, or memoize top-down with `@cache`.", code: topic.template),
                LessonSection(heading: "Space optimization", body: "If `dp[i]` only depends on `dp[i-1]` and `dp[i-2]`, keep two variables instead of an array for O(1) space. Climbing Stairs and House Robber both work this way."),
            ], [
                q("Climbing Stairs (1 or 2 steps at a time): ways(n) = ?", ["2 × ways(n-1)", "ways(n-1) + ways(n-2)", "n²", "2ⁿ"], 1, "Your last move came from step n-1 or step n-2."),
                q("Why does greedy (largest coin first) fail for Coin Change?", ["It's too slow", "A locally best choice can force a worse total", "It uses too much memory", "It doesn't fail"], 1, "With coins [1, 3, 4] and amount 6, greedy uses 4+1+1 (three coins), but 3+3 needs only two."),
            ])
        case .advancedGraphs:
            return ([
                LessonSection(heading: "Weighted shortest paths", body: "With weighted edges, BFS no longer finds shortest paths. **Dijkstra** always expands the closest unfinished node using a min-heap. It needs **non-negative** weights and runs in O(E log V)."),
                LessonSection(heading: "Dijkstra", body: "The first time a node is popped, its distance is final. Skip stale heap entries for nodes that are already finished.", code: topic.template),
                LessonSection(heading: "Minimum spanning trees", body: "To connect every node at minimum total cost, use **Prim's** (grow outward from one node with a heap of edges) or **Kruskal's** (sort edges and add them with union-find, skipping any that would form a cycle)."),
            ], [
                q("Dijkstra's algorithm breaks with…", ["Cycles", "Negative edge weights", "Undirected graphs", "More than 100 nodes"], 1, "It assumes a popped node's distance can't improve later, and negative edges break that assumption."),
                q("\"Connect all points with minimum total cost\" calls for…", ["Topological sort", "A minimum spanning tree", "BFS", "Backtracking"], 1, "An MST connects every node with the minimum total edge weight."),
            ])
        case .dp2d:
            return ([
                LessonSection(heading: "Two indices of state", body: "When a subproblem needs two numbers to describe it, such as a grid cell `(r, c)` or positions `(i, j)` in two strings, store the answers in a 2-D table."),
                LessonSection(heading: "String DP", body: "Compare `a[i]` and `b[j]`. On a match, take both characters. Otherwise, skip one character from either string and keep the better result. LCS, edit distance and many string problems share this shape.", code: topic.template),
                LessonSection(heading: "Grids & saving space", body: "Grid paths: `dp[r][c] = dp[r-1][c] + dp[r][c-1]`. Each row only needs the previous row, so you can often keep a single row for O(n) memory."),
            ], [
                q("Unique Paths: the number of paths to a cell equals…", ["paths above × paths left", "paths above + paths left", "max(above, left)", "1"], 1, "You can only arrive from above or from the left."),
                q("In LCS, when text1[i] != text2[j], dp[i][j] = ?", ["0", "dp[i+1][j+1]", "max(dp[i+1][j], dp[i][j+1])", "1 + dp[i+1][j+1]"], 2, "Skip one character from either string and keep the better result."),
            ])
        case .bitManipulation:
            return ([
                LessonSection(heading: "Think in binary", body: "Integers are just bits. Bitwise operators work on every bit at once in O(1): `&` (and), `|` (or), `^` (xor), `~` (not), and `<<` / `>>` (shift)."),
                LessonSection(heading: "Essential tricks", body: "XOR is the star: identical pairs cancel out, which is how Single Number finds the odd one out in O(1) space.", code: topic.template),
                LessonSection(heading: "Building from smaller numbers", body: "`i >> 1` drops the last bit, so `bits(i) = bits(i >> 1) + (i & 1)`. That's DP over bits.\n\n`n & (n - 1)` clears the lowest set bit, so repeating it until zero counts the set bits."),
            ], [
                q("What is 5 ^ 5 ^ 3?", ["13", "3", "5", "0"], 1, "5 ^ 5 = 0, and 0 ^ 3 = 3."),
                q("For n > 0, `n & (n - 1) == 0` means n is…", ["Odd", "A power of two", "Prime", "Negative"], 1, "A power of two has exactly one set bit, and clearing it leaves 0."),
            ])
        case .intervals:
            return ([
                LessonSection(heading: "Sort first", body: "Interval problems almost always start with a sort: by **start** for merging, or by **end** for fitting in as many intervals as possible. After sorting, each interval only interacts with its neighbor."),
                LessonSection(heading: "Merging", body: "Two sorted intervals overlap when `start <= last_end`. Merge by extending the end to `max(last_end, end)`.", code: topic.template),
                LessonSection(heading: "Greedy scheduling", body: "To keep the **most** non-overlapping intervals, sort by end and always keep the interval that finishes first, since it leaves the most room. For meeting rooms, track end times in a heap."),
            ], [
                q("Merge Intervals: what do you sort by?", ["End", "Start", "Length", "Nothing"], 1, "Sorted by start, only the last merged interval can overlap the next one."),
                q("To remove the fewest intervals so that none overlap, keep the interval that…", ["Starts first", "Ends first", "Is longest", "Is shortest"], 1, "Finishing earliest leaves the most room for the intervals after it."),
            ])
        case .greedy:
            return ([
                LessonSection(heading: "Locally optimal", body: "A greedy algorithm makes the best-looking choice at each step and never revisits it. It's fast and simple, but only correct when a local choice can never hurt the final answer."),
                LessonSection(heading: "Kadane's algorithm", body: "Maximum Subarray: a negative running sum can only drag down what comes next, so drop it and restart. One O(n) pass.", code: topic.template),
                LessonSection(heading: "Prove it (or break it)", body: "Look for a small counterexample. If one breaks the greedy choice, as with Coin Change, you need DP. Jump Game works greedily because the farthest reachable goal captures everything that matters."),
            ], [
                q("Maximum Subarray: the running sum just went negative. You should…", ["Keep it", "Start a new subarray at the next element", "Return 0", "Sort the array"], 1, "A negative prefix only lowers any sum that follows it."),
                q("How do you show that greedy is wrong for a problem?", ["Greedy is always right", "Find one counterexample input", "Show that it's too fast", "Show that it uses recursion"], 1, "A single failing input disproves it, and you'll usually need DP instead."),
            ])
        case .math:
            return ([
                LessonSection(heading: "Matrix manipulation", body: "Many matrix problems break into simple moves. Rotating 90° clockwise = **transpose** + **reverse each row**. Spiral order = walk the four boundaries and shrink them inward."),
                LessonSection(heading: "Rotation in place", body: "A transpose swaps across the diagonal. Loop `j` from `i + 1`, or every pair gets swapped twice and ends up where it started.", code: topic.template),
                LessonSection(heading: "Number tricks", body: "• `n % 10` is the last digit, and `n // 10` drops it.\n• A repeating sequence is a cycle: detect it with a set or fast/slow pointers (Happy Number).\n• Fast power: `x^n = (x^(n/2))²` runs in O(log n)."),
            ], [
                q("How do you rotate a matrix 90° clockwise in place?", ["Reverse rows, then reverse columns", "Transpose, then reverse each row", "Transpose twice", "Sort each row"], 1, "Two reflections combine into a rotation."),
                q("How do you get the last digit of n?", ["n // 10", "n % 10", "n / 10", "n & 10"], 1, "The remainder after dividing by 10 is the ones digit."),
            ])
        }
    }
}
