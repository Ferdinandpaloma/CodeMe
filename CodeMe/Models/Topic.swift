import SwiftUI

/// Topics in roadmap order. `roadmap` arranges them into the tree shown on the home screen.
enum Topic: String, CaseIterable, Identifiable, Hashable {
    case arrays
    case twoPointers
    case stack
    case binarySearch
    case slidingWindow
    case linkedList
    case trees
    case tries
    case heap
    case backtracking
    case graphs
    case dp1d
    case advancedGraphs
    case dp2d
    case bitManipulation
    case intervals
    case greedy
    case math

    var id: String { rawValue }

    static let roadmap: [[Topic]] = [
        [.arrays],
        [.twoPointers, .stack],
        [.binarySearch, .slidingWindow, .linkedList],
        [.trees],
        [.tries, .heap, .backtracking],
        [.graphs, .dp1d],
        [.advancedGraphs, .dp2d, .bitManipulation],
        [.intervals, .greedy, .math],
    ]

    var name: String {
        switch self {
        case .arrays: "Arrays & Hashing"
        case .twoPointers: "Two Pointers"
        case .stack: "Stack"
        case .binarySearch: "Binary Search"
        case .slidingWindow: "Sliding Window"
        case .linkedList: "Linked List"
        case .trees: "Trees"
        case .tries: "Tries"
        case .heap: "Heap / Priority Queue"
        case .backtracking: "Backtracking"
        case .graphs: "Graphs"
        case .dp1d: "1-D Dynamic Programming"
        case .advancedGraphs: "Advanced Graphs"
        case .dp2d: "2-D Dynamic Programming"
        case .bitManipulation: "Bit Manipulation"
        case .intervals: "Intervals"
        case .greedy: "Greedy"
        case .math: "Math & Geometry"
        }
    }

    var shortName: String {
        switch self {
        case .heap: "Heap"
        case .dp1d: "1-D DP"
        case .dp2d: "2-D DP"
        case .bitManipulation: "Bit Manipulation"
        case .math: "Math & Geometry"
        default: name
        }
    }

    var icon: String {
        switch self {
        case .arrays: "number"
        case .twoPointers: "arrow.left.and.right"
        case .stack: "square.stack.3d.up.fill"
        case .binarySearch: "magnifyingglass"
        case .slidingWindow: "rectangle.split.3x1.fill"
        case .linkedList: "link"
        case .trees: "arrow.triangle.branch"
        case .tries: "textformat.abc"
        case .heap: "chart.bar.fill"
        case .backtracking: "arrow.uturn.backward"
        case .graphs: "point.3.connected.trianglepath.dotted"
        case .dp1d: "chart.line.uptrend.xyaxis"
        case .advancedGraphs: "network"
        case .dp2d: "square.grid.3x3.fill"
        case .bitManipulation: "cpu"
        case .intervals: "calendar"
        case .greedy: "bolt.fill"
        case .math: "function"
        }
    }

    var color: Color {
        Palette.topic(Topic.allCases.firstIndex(of: self) ?? 0).color
    }

    var summary: String {
        switch self {
        case .arrays: "Hash maps and sets turn O(n²) lookups into O(1). Most interview problems start here."
        case .twoPointers: "Move two indices toward (or away from) each other to scan a sorted structure in one pass."
        case .stack: "Last-in, first-out. Perfect for matching pairs and finding the next greater/smaller element."
        case .binarySearch: "Halve the search space every step. Works on sorted data and on monotonic answer ranges."
        case .slidingWindow: "Grow and shrink a contiguous window to find the best subarray or substring in O(n)."
        case .linkedList: "Pointer manipulation: dummy nodes, reversing, and fast/slow runners."
        case .trees: "Recursive DFS and level-by-level BFS. Think about what each subtree returns."
        case .tries: "Prefix trees store strings character by character for fast prefix lookups."
        case .heap: "Always know the smallest (or largest) item in O(1). Great for top-k and streaming problems."
        case .backtracking: "Build candidates incrementally, and undo choices that can't lead to a solution."
        case .graphs: "Model relationships as nodes and edges, then explore with DFS, BFS, or topological sort."
        case .dp1d: "Break the problem into overlapping subproblems indexed by a single position."
        case .advancedGraphs: "Weighted shortest paths and minimum spanning trees with heaps."
        case .dp2d: "Subproblems indexed by two dimensions: grids, or a pair of strings."
        case .bitManipulation: "Use binary representations and XOR tricks for constant-space solutions."
        case .intervals: "Sort by start or end, then merge, count, or schedule overlapping ranges."
        case .greedy: "Make the locally optimal choice at each step and prove it's globally optimal."
        case .math: "Matrix manipulation, number properties, and cycle detection."
        }
    }

    /// Signals in a problem statement that hint at this pattern.
    var signals: [String] {
        switch self {
        case .arrays: ["You need to check if something was **seen before**", "Counting frequencies or grouping items by a key", "A brute-force solution compares every pair"]
        case .twoPointers: ["The input is **sorted** (or can be sorted)", "Looking for a pair or triplet with a target sum", "Comparing elements from both ends, like palindromes"]
        case .stack: ["Matching brackets or nested structures", "**Next greater / smaller** element questions", "You need to undo or remember the most recent item"]
        case .binarySearch: ["The input is **sorted** or rotated sorted", "Asked for O(log n)", "Find the **minimum value that works**, where feasibility is monotonic"]
        case .slidingWindow: ["Longest / shortest **contiguous** substring or subarray", "A window must satisfy a constraint (unique chars, at most k changes)", "Streaming over an array with a running condition"]
        case .linkedList: ["Reversing or reordering nodes in place", "Detecting cycles or finding the middle", "Merging sorted lists"]
        case .trees: ["Input is a **binary tree** or BST", "Answer depends on combining left and right subtree results", "Level-by-level processing → BFS"]
        case .tries: ["Many words with **shared prefixes**", "Autocomplete or prefix search", "Wildcard word matching"]
        case .heap: ["**Top k**, k-th largest / smallest", "Repeatedly need the min or max of a changing set", "Median of a stream"]
        case .backtracking: ["Generate **all** subsets, permutations, or combinations", "Constraint puzzles (N-Queens, Sudoku)", "Input size is small (n ≤ 20)"]
        case .graphs: ["Grids of cells connected to neighbors", "Dependencies or prerequisites → **topological sort**", "Shortest steps in an unweighted graph → BFS"]
        case .dp1d: ["Count the **number of ways**, or min / max cost", "The choice at step i depends on earlier steps", "Recursive brute force recomputes the same states"]
        case .advancedGraphs: ["**Weighted** edges and shortest time / cost → Dijkstra", "Connect all nodes with minimum total cost → MST", "Union-find for connectivity"]
        case .dp2d: ["Grid paths", "Comparing **two strings** (LCS, edit distance)", "State needs two indices"]
        case .bitManipulation: ["Every element appears twice except one", "Counting set bits", "Asked to avoid extra space or arithmetic operators"]
        case .intervals: ["Input is a list of **[start, end]** pairs", "Merging, inserting, or removing overlaps", "Meeting rooms / scheduling"]
        case .greedy: ["Max subarray, jump reachability", "A local choice never needs revisiting", "Sorting first makes the choice obvious"]
        case .math: ["Rotate or spiral a matrix in place", "Digit manipulation", "Detecting repeating number sequences"]
        }
    }

    var template: String {
        switch self {
        case .arrays: #"""
            # Hash map: O(1) "have I seen this?" lookups
            seen = {}  # value -> index
            for i, x in enumerate(nums):
                if target - x in seen:
                    return [seen[target - x], i]
                seen[x] = i
            """#
        case .twoPointers: #"""
            l, r = 0, len(nums) - 1
            while l < r:
                total = nums[l] + nums[r]
                if total == target:
                    return [l, r]
                elif total < target:
                    l += 1  # need a bigger sum
                else:
                    r -= 1  # need a smaller sum
            """#
        case .stack: #"""
            # Monotonic stack: next greater element
            result = [-1] * len(nums)
            stack = []  # indices, values decreasing
            for i, x in enumerate(nums):
                while stack and nums[stack[-1]] < x:
                    j = stack.pop()
                    result[j] = x
                stack.append(i)
            """#
        case .binarySearch: #"""
            # Find the smallest value where feasible() is True
            l, r = lo, hi
            while l < r:
                mid = (l + r) // 2
                if feasible(mid):
                    r = mid       # mid works, look left
                else:
                    l = mid + 1   # mid fails, look right
            return l
            """#
        case .slidingWindow: #"""
            l = 0
            window = {}
            best = 0
            for r, x in enumerate(s):
                window[x] = window.get(x, 0) + 1
                while window_is_invalid(window):
                    window[s[l]] -= 1
                    l += 1
                best = max(best, r - l + 1)
            """#
        case .linkedList: #"""
            # Fast / slow pointers
            slow = fast = head
            while fast and fast.next:
                slow = slow.next
                fast = fast.next.next
            # slow is now the middle node

            # Reverse in place
            prev, curr = None, head
            while curr:
                curr.next, prev, curr = prev, curr, curr.next
            """#
        case .trees: #"""
            def dfs(node):
                if not node:
                    return 0  # base case
                left = dfs(node.left)
                right = dfs(node.right)
                return combine(node.val, left, right)

            # BFS level by level
            queue = deque([root])
            while queue:
                for _ in range(len(queue)):
                    node = queue.popleft()
            """#
        case .tries: #"""
            class TrieNode:
                def __init__(self):
                    self.children = {}
                    self.is_end = False

            def insert(root, word):
                node = root
                for c in word:
                    node = node.children.setdefault(c, TrieNode())
                node.is_end = True
            """#
        case .heap: #"""
            import heapq

            # Keep the k largest items: min-heap of size k
            heap = []
            for x in nums:
                heapq.heappush(heap, x)
                if len(heap) > k:
                    heapq.heappop(heap)
            return heap[0]  # k-th largest

            # Max-heap trick: push negatives
            heapq.heappush(max_heap, -x)
            """#
        case .backtracking: #"""
            result, path = [], []

            def backtrack(start):
                if is_complete(path):
                    result.append(path.copy())
                    return
                for i in range(start, len(choices)):
                    path.append(choices[i])   # choose
                    backtrack(i + 1)          # explore
                    path.pop()                # un-choose
            """#
        case .graphs: #"""
            def bfs(start):
                queue = deque([start])
                visited = {start}
                while queue:
                    node = queue.popleft()
                    for nxt in graph[node]:
                        if nxt not in visited:
                            visited.add(nxt)
                            queue.append(nxt)

            # Grid neighbors
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nr, nc = r + dr, c + dc
            """#
        case .dp1d: #"""
            # Bottom-up: dp[i] built from smaller subproblems
            dp = [0] * (n + 1)
            dp[0] = base_case
            for i in range(1, n + 1):
                dp[i] = max(dp[i - 1], dp[i - 2] + nums[i - 1])
            return dp[n]

            # Top-down alternative
            @cache
            def solve(i):
                return solve(i - 1) + solve(i - 2)
            """#
        case .advancedGraphs: #"""
            # Dijkstra: shortest path with non-negative weights
            dist = {}
            heap = [(0, source)]
            while heap:
                d, node = heapq.heappop(heap)
                if node in dist:
                    continue
                dist[node] = d
                for nxt, w in graph[node]:
                    if nxt not in dist:
                        heapq.heappush(heap, (d + w, nxt))
            """#
        case .dp2d: #"""
            m, n = len(a), len(b)
            dp = [[0] * (n + 1) for _ in range(m + 1)]
            for i in range(1, m + 1):
                for j in range(1, n + 1):
                    if a[i - 1] == b[j - 1]:
                        dp[i][j] = dp[i - 1][j - 1] + 1
                    else:
                        dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
            return dp[m][n]
            """#
        case .bitManipulation: #"""
            x & 1          # is the lowest bit set?
            x >> 1         # divide by 2
            x & (x - 1)    # drop the lowest set bit
            a ^ a == 0     # XOR cancels pairs
            a ^ 0 == a     # XOR with 0 is identity
            """#
        case .intervals: #"""
            intervals.sort(key=lambda x: x[0])
            merged = [intervals[0]]
            for start, end in intervals[1:]:
                if start <= merged[-1][1]:   # overlap
                    merged[-1][1] = max(merged[-1][1], end)
                else:
                    merged.append([start, end])
            """#
        case .greedy: #"""
            # Kadane's algorithm
            best = current = nums[0]
            for x in nums[1:]:
                current = max(x, current + x)  # extend or restart
                best = max(best, current)
            return best
            """#
        case .math: #"""
            # Rotate an n x n matrix 90° clockwise in place
            for i in range(n):
                for j in range(i + 1, n):
                    m[i][j], m[j][i] = m[j][i], m[i][j]  # transpose
            for row in m:
                row.reverse()                            # mirror
            """#
        }
    }
}
