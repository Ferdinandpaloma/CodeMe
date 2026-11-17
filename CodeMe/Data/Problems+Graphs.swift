import Foundation

extension ProblemBank {
    static let heap: [Problem] = [
        Problem(
            id: "last-stone-weight", number: 1046, title: "Last Stone Weight", difficulty: .easy, topic: .heap,
            description: "You have an array of `stones`. Each turn, smash the two **heaviest** stones together:\n\n• If they're equal, both are destroyed.\n• Otherwise the lighter is destroyed and the heavier loses that much weight.\n\nReturn the weight of the last stone, or `0` if none remain.",
            examples: [ex("stones = [2,7,4,1,8,1]", "1"), ex("stones = [1]", "1")],
            constraints: ["1 ≤ stones.length ≤ 30", "1 ≤ stones[i] ≤ 1000"],
            hints: ["You repeatedly need the two largest values.", "Python's `heapq` is a min-heap. Store negatives to simulate a max-heap."],
            approach: ["Build a **max-heap** by negating every stone.", "Pop the two heaviest; if they differ, push back their difference.", "Repeat until at most one stone is left."],
            solution: #"""
            class Solution:
                def lastStoneWeight(self, stones: List[int]) -> int:
                    heap = [-s for s in stones]  # max-heap via negatives
                    heapq.heapify(heap)
                    while len(heap) > 1:
                        first = -heapq.heappop(heap)
                        second = -heapq.heappop(heap)
                        if first != second:
                            heapq.heappush(heap, -(first - second))
                    return -heap[0] if heap else 0
            """#,
            time: "O(n log n)", space: "O(n)"),

        Problem(
            id: "k-closest-points-to-origin", number: 973, title: "K Closest Points to Origin", difficulty: .medium, topic: .heap,
            description: "Given an array of `points` where `points[i] = [x, y]` and an integer `k`, return the `k` points **closest to the origin** `(0, 0)` by Euclidean distance, in any order.",
            examples: [ex("points = [[1,3],[-2,2]], k = 1", "[[-2,2]]", "√8 < √10, so [-2,2] is closer."), ex("points = [[3,3],[5,-1],[-2,4]], k = 2", "[[3,3],[-2,4]]")],
            constraints: ["1 ≤ k ≤ points.length ≤ 10⁴", "-10⁴ ≤ x, y ≤ 10⁴"],
            hints: ["You don't need the square root to compare distances.", "Keep only the k best candidates seen so far in a heap of size k."],
            approach: ["Use a **max-heap of size k** keyed by squared distance (negated for `heapq`).", "Push each point; if the heap grows beyond `k`, pop the farthest.", "The heap holds the `k` closest points at the end."],
            solution: #"""
            class Solution:
                def kClosest(self, points: List[List[int]], k: int) -> List[List[int]]:
                    heap = []  # max-heap of size k (negative distance)
                    for x, y in points:
                        dist = -(x * x + y * y)
                        heapq.heappush(heap, (dist, x, y))
                        if len(heap) > k:
                            heapq.heappop(heap)
                    return [[x, y] for _, x, y in heap]
            """#,
            time: "O(n log k)", space: "O(k)"),

        Problem(
            id: "find-median-from-data-stream", number: 295, title: "Find Median from Data Stream", difficulty: .hard, topic: .heap,
            description: "Design a `MedianFinder` that supports:\n\n• `addNum(num)` adds an integer from the stream.\n• `findMedian()` returns the median of all numbers so far.",
            examples: [ex("addNum(1), addNum(2), findMedian(), addNum(3), findMedian()", "1.5, 2.0")],
            constraints: ["-10⁵ ≤ num ≤ 10⁵", "findMedian is called only after at least one addNum", "At most 5 · 10⁴ calls"],
            hints: ["Split the numbers into a lower half and an upper half.", "You only need the largest of the lower half and the smallest of the upper half."],
            approach: ["Keep a **max-heap** `small` for the lower half and a **min-heap** `large` for the upper half.", "On add, push into `small`, move its max to `large`, then rebalance so `small` is equal or one bigger.", "The median is `small`'s top, or the average of both tops."],
            solution: #"""
            class MedianFinder:
                def __init__(self):
                    self.small = []  # max-heap (negated) for the lower half
                    self.large = []  # min-heap for the upper half

                def addNum(self, num: int) -> None:
                    heapq.heappush(self.small, -num)
                    # move the largest of the lower half to the upper half
                    heapq.heappush(self.large, -heapq.heappop(self.small))
                    # keep small the same size or one bigger
                    if len(self.large) > len(self.small):
                        heapq.heappush(self.small, -heapq.heappop(self.large))

                def findMedian(self) -> float:
                    if len(self.small) > len(self.large):
                        return -self.small[0]
                    return (-self.small[0] + self.large[0]) / 2
            """#,
            time: "O(log n) add, O(1) median", space: "O(n)"),
    ]

    static let backtracking: [Problem] = [
        Problem(
            id: "subsets", number: 78, title: "Subsets", difficulty: .medium, topic: .backtracking,
            description: "Given an array `nums` of **unique** integers, return all possible subsets (the power set). The answer must not contain duplicates.",
            examples: [ex("nums = [1,2,3]", "[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]"), ex("nums = [0]", "[[],[0]]")],
            constraints: ["1 ≤ nums.length ≤ 10", "All values are unique"],
            hints: ["Each element is either in the subset or not.", "That's a binary decision tree of depth n."],
            approach: ["At index `i`, branch twice: **include** `nums[i]` or **skip** it.", "When `i` reaches the end, record a copy of the current subset.", "Undo the choice (`pop`) before exploring the skip branch."],
            solution: #"""
            class Solution:
                def subsets(self, nums: List[int]) -> List[List[int]]:
                    result, subset = [], []

                    def backtrack(i):
                        if i == len(nums):
                            result.append(subset.copy())
                            return
                        subset.append(nums[i])  # include nums[i]
                        backtrack(i + 1)
                        subset.pop()            # skip nums[i]
                        backtrack(i + 1)

                    backtrack(0)
                    return result
            """#,
            time: "O(n · 2ⁿ)", space: "O(n)"),

        Problem(
            id: "combination-sum", number: 39, title: "Combination Sum", difficulty: .medium, topic: .backtracking,
            description: "Given distinct integers `candidates` and a `target`, return all unique combinations that sum to `target`. Each number may be used an **unlimited** number of times.",
            examples: [ex("candidates = [2,3,6,7], target = 7", "[[2,2,3],[7]]"), ex("candidates = [2,3,5], target = 8", "[[2,2,2,2],[2,3,3],[3,5]]")],
            constraints: ["1 ≤ candidates.length ≤ 30", "2 ≤ candidates[i] ≤ 40", "1 ≤ target ≤ 40"],
            hints: ["To avoid duplicate combinations, never pick an index smaller than the last one you chose.", "Since reuse is allowed, recurse with the same index."],
            approach: ["Backtrack with `(start, remaining)`.", "Try each candidate from `start` onward; recurse with the **same** index to allow reuse.", "Record the combo when `remaining == 0`; prune when a candidate exceeds `remaining`."],
            solution: #"""
            class Solution:
                def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
                    result, combo = [], []

                    def backtrack(start, remaining):
                        if remaining == 0:
                            result.append(combo.copy())
                            return
                        for i in range(start, len(candidates)):
                            if candidates[i] <= remaining:
                                combo.append(candidates[i])
                                backtrack(i, remaining - candidates[i])  # reuse allowed
                                combo.pop()

                    backtrack(0, target)
                    return result
            """#,
            time: "O(n^(t/m))", space: "O(t/m)"),

        Problem(
            id: "permutations", number: 46, title: "Permutations", difficulty: .medium, topic: .backtracking,
            description: "Given an array `nums` of distinct integers, return **all possible orderings** (permutations) in any order.",
            examples: [ex("nums = [1,2,3]", "[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]"), ex("nums = [0,1]", "[[0,1],[1,0]]")],
            constraints: ["1 ≤ nums.length ≤ 6", "All integers are unique"],
            hints: ["At each position, any unused number can go next.", "Track which numbers are already in the current permutation."],
            approach: ["Build a permutation one slot at a time.", "For each slot, try every number not yet `used`.", "Undo the choice after exploring so the next candidate can be tried."],
            solution: #"""
            class Solution:
                def permute(self, nums: List[int]) -> List[List[int]]:
                    result, perm = [], []
                    used = [False] * len(nums)

                    def backtrack():
                        if len(perm) == len(nums):
                            result.append(perm.copy())
                            return
                        for i, n in enumerate(nums):
                            if not used[i]:
                                used[i] = True
                                perm.append(n)
                                backtrack()
                                perm.pop()
                                used[i] = False

                    backtrack()
                    return result
            """#,
            time: "O(n · n!)", space: "O(n)"),
    ]

    static let graphs: [Problem] = [
        Problem(
            id: "number-of-islands", number: 200, title: "Number of Islands", difficulty: .medium, topic: .graphs,
            description: "Given an `m × n` grid of `\"1\"` (land) and `\"0\"` (water), return the number of **islands**. An island is land connected horizontally or vertically and surrounded by water.",
            examples: [ex(#"grid = [["1","1","0"],["1","0","0"],["0","0","1"]]"#, "2")],
            constraints: ["1 ≤ m, n ≤ 300", "grid[i][j] is \"0\" or \"1\""],
            hints: ["Each time you find unvisited land, you've found a new island.", "Flood-fill the whole island so you don't count it again."],
            approach: ["Scan every cell.", "When you find a `\"1\"`, increment the count and **flood fill** (DFS) to sink the entire island.", "Sunk cells become `\"0\"`, so each island is counted once."],
            solution: #"""
            class Solution:
                def numIslands(self, grid: List[List[str]]) -> int:
                    rows, cols = len(grid), len(grid[0])

                    def sink(r, c):
                        if r < 0 or c < 0 or r >= rows or c >= cols or grid[r][c] != "1":
                            return
                        grid[r][c] = "0"  # mark visited
                        sink(r + 1, c)
                        sink(r - 1, c)
                        sink(r, c + 1)
                        sink(r, c - 1)

                    islands = 0
                    for r in range(rows):
                        for c in range(cols):
                            if grid[r][c] == "1":
                                islands += 1
                                sink(r, c)
                    return islands
            """#,
            time: "O(m · n)", space: "O(m · n)"),

        Problem(
            id: "clone-graph", number: 133, title: "Clone Graph", difficulty: .medium, topic: .graphs,
            description: "Given a reference to a node in a connected undirected graph, return a **deep copy** of the graph. Each node has a `val` and a list of `neighbors`.",
            examples: [ex("adjList = [[2,4],[1,3],[2,4],[1,3]]", "[[2,4],[1,3],[2,4],[1,3]]"), ex("adjList = [[]]", "[[]]")],
            constraints: ["0 ≤ number of nodes ≤ 100", "Node values are unique, 1 to 100", "No repeated edges or self-loops"],
            hints: ["Graphs have cycles. How do you avoid cloning the same node forever?", "Map each original node to its copy."],
            approach: ["Keep a hash map **original → clone**.", "DFS: if a node was already cloned, return the clone.", "Otherwise create the clone, store it **before** recursing, then clone each neighbor."],
            solution: #"""
            # Definition for a Node.
            # class Node:
            #     def __init__(self, val=0, neighbors=None):
            #         self.val = val
            #         self.neighbors = neighbors if neighbors is not None else []

            class Solution:
                def cloneGraph(self, node: Optional["Node"]) -> Optional["Node"]:
                    clones = {}

                    def clone(n):
                        if n in clones:
                            return clones[n]
                        copy = Node(n.val)
                        clones[n] = copy
                        for nb in n.neighbors:
                            copy.neighbors.append(clone(nb))
                        return copy

                    return clone(node) if node else None
            """#,
            time: "O(V + E)", space: "O(V)"),

        Problem(
            id: "rotting-oranges", number: 994, title: "Rotting Oranges", difficulty: .medium, topic: .graphs,
            description: "In a grid, `0` is empty, `1` is a fresh orange, and `2` is a rotten orange. Each minute, fresh oranges next to a rotten one (4 directions) become rotten.\n\nReturn the minimum minutes until no fresh orange remains, or `-1` if that's impossible.",
            examples: [ex("grid = [[2,1,1],[1,1,0],[0,1,1]]", "4"), ex("grid = [[2,1,1],[0,1,1],[1,0,1]]", "-1", "The bottom-left orange is never reached.")],
            constraints: ["1 ≤ m, n ≤ 10", "grid[i][j] is 0, 1 or 2"],
            hints: ["The rot spreads from all rotten oranges at the same time.", "Multi-source BFS: start the queue with every rotten orange."],
            approach: ["Put every rotten orange in the queue and count fresh ones.", "Process the queue **one level per minute**, rotting fresh neighbors.", "When the queue empties, return minutes if no fresh oranges remain, else `-1`."],
            solution: #"""
            class Solution:
                def orangesRotting(self, grid: List[List[int]]) -> int:
                    rows, cols = len(grid), len(grid[0])
                    queue = deque()
                    fresh = 0
                    for r in range(rows):
                        for c in range(cols):
                            if grid[r][c] == 2:
                                queue.append((r, c))
                            elif grid[r][c] == 1:
                                fresh += 1

                    minutes = 0
                    while queue and fresh:
                        for _ in range(len(queue)):
                            r, c = queue.popleft()
                            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                                nr, nc = r + dr, c + dc
                                if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] == 1:
                                    grid[nr][nc] = 2
                                    fresh -= 1
                                    queue.append((nr, nc))
                        minutes += 1
                    return minutes if fresh == 0 else -1
            """#,
            time: "O(m · n)", space: "O(m · n)"),

        Problem(
            id: "course-schedule", number: 207, title: "Course Schedule", difficulty: .medium, topic: .graphs,
            description: "There are `numCourses` courses labeled `0` to `numCourses - 1`. `prerequisites[i] = [a, b]` means you must take `b` before `a`.\n\nReturn `true` if you can finish every course.",
            examples: [ex("numCourses = 2, prerequisites = [[1,0]]", "true"), ex("numCourses = 2, prerequisites = [[1,0],[0,1]]", "false", "Each course requires the other, which is a cycle.")],
            constraints: ["1 ≤ numCourses ≤ 2000", "0 ≤ prerequisites.length ≤ 5000", "All pairs are unique"],
            hints: ["You can finish all courses exactly when the prerequisite graph has no cycle.", "Topological sort: repeatedly take courses with no remaining prerequisites."],
            approach: ["Build a graph `pre → course` and count each course's **in-degree**.", "Start a queue with all courses that have in-degree 0 (**Kahn's algorithm**).", "Taking a course lowers its dependents' in-degree; if every course gets taken, there's no cycle."],
            solution: #"""
            class Solution:
                def canFinish(self, numCourses: int, prerequisites: List[List[int]]) -> bool:
                    graph = defaultdict(list)
                    indegree = [0] * numCourses
                    for course, pre in prerequisites:
                        graph[pre].append(course)
                        indegree[course] += 1

                    queue = deque(i for i in range(numCourses) if indegree[i] == 0)
                    taken = 0
                    while queue:
                        node = queue.popleft()
                        taken += 1
                        for nxt in graph[node]:
                            indegree[nxt] -= 1
                            if indegree[nxt] == 0:
                                queue.append(nxt)
                    return taken == numCourses
            """#,
            time: "O(V + E)", space: "O(V + E)"),
    ]

    static let advancedGraphs: [Problem] = [
        Problem(
            id: "network-delay-time", number: 743, title: "Network Delay Time", difficulty: .medium, topic: .advancedGraphs,
            description: "You're given a network of `n` nodes and directed travel times `times[i] = (u, v, w)`. A signal is sent from node `k`.\n\nReturn the time it takes for **all** nodes to receive the signal, or `-1` if some node never does.",
            examples: [ex("times = [[2,1,1],[2,3,1],[3,4,1]], n = 4, k = 2", "2"), ex("times = [[1,2,1]], n = 2, k = 2", "-1")],
            constraints: ["1 ≤ k ≤ n ≤ 100", "1 ≤ times.length ≤ 6000", "0 ≤ w ≤ 100"],
            hints: ["You need the shortest path from k to every node.", "All weights are non-negative, which is Dijkstra's territory."],
            approach: ["Run **Dijkstra** from `k` using a min-heap of `(distance, node)`.", "The first time a node is popped, its distance is final.", "If every node is reached, the answer is the largest of those distances."],
            solution: #"""
            class Solution:
                def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
                    graph = defaultdict(list)
                    for u, v, w in times:
                        graph[u].append((v, w))

                    dist = {}
                    heap = [(0, k)]
                    while heap:
                        d, node = heapq.heappop(heap)
                        if node in dist:
                            continue
                        dist[node] = d
                        for nxt, w in graph[node]:
                            if nxt not in dist:
                                heapq.heappush(heap, (d + w, nxt))
                    return max(dist.values()) if len(dist) == n else -1
            """#,
            time: "O(E log V)", space: "O(V + E)"),

        Problem(
            id: "min-cost-to-connect-all-points", number: 1584, title: "Min Cost to Connect All Points", difficulty: .medium, topic: .advancedGraphs,
            description: "Given `points` on a 2D plane, the cost to connect two points is their **Manhattan distance** `|x1 - x2| + |y1 - y2|`.\n\nReturn the minimum cost to connect all points so that every pair is connected by exactly one simple path.",
            examples: [ex("points = [[0,0],[2,2],[3,10],[5,2],[7,0]]", "20"), ex("points = [[3,12],[-2,5],[-4,1]]", "18")],
            constraints: ["1 ≤ points.length ≤ 1000", "-10⁶ ≤ x, y ≤ 10⁶", "All points are distinct"],
            hints: ["\"Connect everything with minimum total cost\" is a minimum spanning tree.", "Prim's algorithm grows the tree one cheapest edge at a time."],
            approach: ["Use **Prim's algorithm** with a min-heap of `(cost, point)`.", "Pop the cheapest unvisited point, add its cost, and mark it visited.", "Push edges from it to every unvisited point; stop when all points are in the tree."],
            solution: #"""
            class Solution:
                def minCostConnectPoints(self, points: List[List[int]]) -> int:
                    n = len(points)
                    visited = set()
                    heap = [(0, 0)]  # (cost, point index)
                    total = 0
                    while len(visited) < n:
                        cost, i = heapq.heappop(heap)
                        if i in visited:
                            continue
                        visited.add(i)
                        total += cost
                        xi, yi = points[i]
                        for j in range(n):
                            if j not in visited:
                                xj, yj = points[j]
                                heapq.heappush(heap, (abs(xi - xj) + abs(yi - yj), j))
                    return total
            """#,
            time: "O(n² log n)", space: "O(n²)"),
    ]
}
