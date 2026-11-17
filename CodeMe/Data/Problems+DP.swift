import Foundation

extension ProblemBank {
    static let dp1d: [Problem] = [
        Problem(
            id: "climbing-stairs", number: 70, title: "Climbing Stairs", difficulty: .easy, topic: .dp1d,
            description: "You're climbing a staircase with `n` steps. Each time you can climb **1 or 2** steps.\n\nIn how many distinct ways can you reach the top?",
            examples: [ex("n = 2", "2", "1+1 or 2"), ex("n = 3", "3", "1+1+1, 1+2, or 2+1")],
            constraints: ["1 ≤ n ≤ 45"],
            hints: ["To stand on step n, your last move came from step n-1 or n-2.", "ways(n) = ways(n-1) + ways(n-2). Look familiar?"],
            approach: ["The last move was either 1 step or 2 steps, so `ways(n) = ways(n-1) + ways(n-2)`.", "That's the **Fibonacci** recurrence.", "Only the previous two values matter, so keep two variables instead of a full array."],
            solution: #"""
            class Solution:
                def climbStairs(self, n: int) -> int:
                    one, two = 1, 1  # ways to reach step i and i-1
                    for _ in range(n - 1):
                        one, two = one + two, one
                    return one
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "house-robber", number: 198, title: "House Robber", difficulty: .medium, topic: .dp1d,
            description: "Houses along a street hold `nums[i]` money. You can't rob two **adjacent** houses (it triggers an alarm).\n\nReturn the maximum amount you can rob.",
            examples: [ex("nums = [1,2,3,1]", "4", "Rob house 0 and 2: 1 + 3."), ex("nums = [2,7,9,3,1]", "12", "Rob houses 0, 2 and 4: 2 + 9 + 1.")],
            constraints: ["1 ≤ nums.length ≤ 100", "0 ≤ nums[i] ≤ 400"],
            hints: ["At each house: rob it (and add the best from two houses back) or skip it.", "best(i) = max(best(i-1), best(i-2) + nums[i])"],
            approach: ["For each house, choose the better of **skipping** it (`curr`) or **robbing** it (`prev + n`).", "Roll two variables forward: `prev` is the best up to i-2, `curr` up to i-1.", "Return `curr` at the end."],
            solution: #"""
            class Solution:
                def rob(self, nums: List[int]) -> int:
                    prev, curr = 0, 0
                    for n in nums:
                        prev, curr = curr, max(curr, prev + n)
                    return curr
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "coin-change", number: 322, title: "Coin Change", difficulty: .medium, topic: .dp1d,
            description: "Given coin denominations `coins` and a total `amount`, return the **fewest coins** needed to make that amount, or `-1` if it can't be made. You have unlimited coins of each kind.",
            examples: [ex("coins = [1,2,5], amount = 11", "3", "11 = 5 + 5 + 1"), ex("coins = [2], amount = 3", "-1"), ex("coins = [1], amount = 0", "0")],
            constraints: ["1 ≤ coins.length ≤ 12", "1 ≤ coins[i] ≤ 2³¹ - 1", "0 ≤ amount ≤ 10⁴"],
            hints: ["Greedy (always the biggest coin) fails for coins like [1, 3, 4] and amount 6.", "dp[a] = 1 + min(dp[a - coin]) over all coins."],
            approach: ["`dp[a]` = fewest coins to make amount `a`; `dp[0] = 0`.", "For each amount, try every coin as the **last coin**: `dp[a - coin] + 1`.", "If `dp[amount]` is still infinity, it's impossible."],
            solution: #"""
            class Solution:
                def coinChange(self, coins: List[int], amount: int) -> int:
                    dp = [0] + [float("inf")] * amount  # dp[a] = fewest coins for a
                    for a in range(1, amount + 1):
                        for coin in coins:
                            if coin <= a:
                                dp[a] = min(dp[a], dp[a - coin] + 1)
                    return dp[amount] if dp[amount] != float("inf") else -1
            """#,
            time: "O(amount · coins)", space: "O(amount)"),

        Problem(
            id: "longest-increasing-subsequence", number: 300, title: "Longest Increasing Subsequence", difficulty: .medium, topic: .dp1d,
            description: "Given an integer array `nums`, return the length of the longest **strictly increasing subsequence**.",
            examples: [ex("nums = [10,9,2,5,3,7,101,18]", "4", "One answer is [2,3,7,101]."), ex("nums = [0,1,0,3,2,3]", "4"), ex("nums = [7,7,7,7]", "1")],
            constraints: ["1 ≤ nums.length ≤ 2500", "-10⁴ ≤ nums[i] ≤ 10⁴"],
            hints: ["O(n²) DP: dp[i] = 1 + max(dp[j]) for j < i with nums[j] < nums[i].", "For O(n log n), keep the smallest possible tail for each subsequence length."],
            approach: ["Maintain `tails`, where `tails[i]` is the smallest tail of any increasing subsequence of length `i + 1`.", "For each number, **binary search** its position in `tails`.", "Append if it extends the longest; otherwise replace to keep tails as small as possible."],
            solution: #"""
            class Solution:
                def lengthOfLIS(self, nums: List[int]) -> int:
                    tails = []  # tails[i] = smallest tail of an increasing subsequence of length i+1
                    for n in nums:
                        i = bisect_left(tails, n)
                        if i == len(tails):
                            tails.append(n)
                        else:
                            tails[i] = n
                    return len(tails)
            """#,
            time: "O(n log n)", space: "O(n)"),
    ]

    static let dp2d: [Problem] = [
        Problem(
            id: "unique-paths", number: 62, title: "Unique Paths", difficulty: .medium, topic: .dp2d,
            description: "A robot starts at the top-left of an `m × n` grid and can only move **right** or **down**.\n\nHow many unique paths lead to the bottom-right corner?",
            examples: [ex("m = 3, n = 7", "28"), ex("m = 3, n = 2", "3")],
            constraints: ["1 ≤ m, n ≤ 100"],
            hints: ["Paths to a cell = paths to the cell above + paths to the cell on the left.", "You only need the previous row at any time."],
            approach: ["Every cell in the first row and column has exactly 1 path.", "Each other cell: `paths[r][c] = paths[r-1][c] + paths[r][c-1]`.", "Keep a single row and update it in place, row by row."],
            solution: #"""
            class Solution:
                def uniquePaths(self, m: int, n: int) -> int:
                    row = [1] * n
                    for _ in range(m - 1):
                        for c in range(1, n):
                            row[c] += row[c - 1]  # from above + from left
                    return row[-1]
            """#,
            time: "O(m · n)", space: "O(n)"),

        Problem(
            id: "longest-common-subsequence", number: 1143, title: "Longest Common Subsequence", difficulty: .medium, topic: .dp2d,
            description: "Given strings `text1` and `text2`, return the length of their longest **common subsequence**, meaning characters that appear in both strings in the same relative order (not necessarily contiguous).",
            examples: [ex(#"text1 = "abcde", text2 = "ace""#, "3", #"The LCS is "ace"."#), ex(#"text1 = "abc", text2 = "def""#, "0")],
            constraints: ["1 ≤ text1.length, text2.length ≤ 1000", "Lowercase English letters only"],
            hints: ["Compare the first characters of both suffixes.", "If they match, take both. Otherwise skip one character from either string."],
            approach: ["`dp[i][j]` = LCS of `text1[i:]` and `text2[j:]`.", "If `text1[i] == text2[j]`: `1 + dp[i+1][j+1]`.", "Otherwise: `max(dp[i+1][j], dp[i][j+1])`. Fill the table bottom-up from the end."],
            solution: #"""
            class Solution:
                def longestCommonSubsequence(self, text1: str, text2: str) -> int:
                    m, n = len(text1), len(text2)
                    dp = [[0] * (n + 1) for _ in range(m + 1)]
                    for i in range(m - 1, -1, -1):
                        for j in range(n - 1, -1, -1):
                            if text1[i] == text2[j]:
                                dp[i][j] = 1 + dp[i + 1][j + 1]
                            else:
                                dp[i][j] = max(dp[i + 1][j], dp[i][j + 1])
                    return dp[0][0]
            """#,
            time: "O(m · n)", space: "O(m · n)"),
    ]

    static let greedy: [Problem] = [
        Problem(
            id: "maximum-subarray", number: 53, title: "Maximum Subarray", difficulty: .medium, topic: .greedy,
            description: "Given an integer array `nums`, find the contiguous **subarray** with the largest sum and return that sum.",
            examples: [ex("nums = [-2,1,-3,4,-1,2,1,-5,4]", "6", "The subarray [4,-1,2,1] sums to 6."), ex("nums = [5,4,-1,7,8]", "23")],
            constraints: ["1 ≤ nums.length ≤ 10⁵", "-10⁴ ≤ nums[i] ≤ 10⁴"],
            hints: ["If the running sum becomes negative, does it help any future subarray?", "This is Kadane's algorithm."],
            approach: ["Track `current`, the best sum of a subarray **ending here**.", "Either extend the previous subarray or start fresh: `max(n, current + n)`.", "Track the best `current` seen."],
            solution: #"""
            class Solution:
                def maxSubArray(self, nums: List[int]) -> int:
                    best = nums[0]
                    current = 0
                    for n in nums:
                        current = max(n, current + n)  # extend or restart
                        best = max(best, current)
                    return best
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "jump-game", number: 55, title: "Jump Game", difficulty: .medium, topic: .greedy,
            description: "You start at index 0 of `nums`. Each element is your **maximum** jump length from that position.\n\nReturn `true` if you can reach the last index.",
            examples: [ex("nums = [2,3,1,1,4]", "true", "Jump 1 step to index 1, then 3 steps to the end."), ex("nums = [3,2,1,0,4]", "false", "You always land on index 3, whose jump length is 0.")],
            constraints: ["1 ≤ nums.length ≤ 10⁴", "0 ≤ nums[i] ≤ 10⁵"],
            hints: ["Work backward: which positions can reach the end?", "If position i can reach the current goal, i becomes the new goal."],
            approach: ["Set the **goal** to the last index.", "Walk backward; if `i + nums[i] >= goal`, move the goal to `i`.", "You can win if the goal reaches index 0."],
            solution: #"""
            class Solution:
                def canJump(self, nums: List[int]) -> bool:
                    goal = len(nums) - 1
                    for i in range(len(nums) - 2, -1, -1):
                        if i + nums[i] >= goal:
                            goal = i  # i can reach the goal, so it becomes the new goal
                    return goal == 0
            """#,
            time: "O(n)", space: "O(1)"),
    ]

    static let intervals: [Problem] = [
        Problem(
            id: "merge-intervals", number: 56, title: "Merge Intervals", difficulty: .medium, topic: .intervals,
            description: "Given an array of `intervals` where `intervals[i] = [start, end]`, merge all **overlapping** intervals and return the non-overlapping result.",
            examples: [ex("intervals = [[1,3],[2,6],[8,10],[15,18]]", "[[1,6],[8,10],[15,18]]"), ex("intervals = [[1,4],[4,5]]", "[[1,5]]", "Touching intervals count as overlapping.")],
            constraints: ["1 ≤ intervals.length ≤ 10⁴", "0 ≤ start ≤ end ≤ 10⁴"],
            hints: ["Sort by start time first.", "After sorting, an interval can only overlap the last merged interval."],
            approach: ["**Sort** intervals by start.", "If the next interval starts before the last merged one ends, extend the end.", "Otherwise append it as a new interval."],
            solution: #"""
            class Solution:
                def merge(self, intervals: List[List[int]]) -> List[List[int]]:
                    intervals.sort(key=lambda x: x[0])
                    merged = [intervals[0]]
                    for start, end in intervals[1:]:
                        if start <= merged[-1][1]:
                            merged[-1][1] = max(merged[-1][1], end)
                        else:
                            merged.append([start, end])
                    return merged
            """#,
            time: "O(n log n)", space: "O(n)"),

        Problem(
            id: "non-overlapping-intervals", number: 435, title: "Non-overlapping Intervals", difficulty: .medium, topic: .intervals,
            description: "Given an array of `intervals`, return the **minimum number** of intervals you need to remove so the rest don't overlap. Intervals that only touch (like `[1,2]` and `[2,3]`) don't overlap.",
            examples: [ex("intervals = [[1,2],[2,3],[3,4],[1,3]]", "1", "Remove [1,3]."), ex("intervals = [[1,2],[1,2],[1,2]]", "2")],
            constraints: ["1 ≤ intervals.length ≤ 10⁵", "-5 · 10⁴ ≤ start < end ≤ 5 · 10⁴"],
            hints: ["Keep as many intervals as possible. Which interval leaves the most room for the rest?", "Always keep the interval that ends earliest."],
            approach: ["Sort intervals by **end** time.", "Greedily keep an interval if it starts at or after the last kept end.", "Every interval that conflicts is removed; count them."],
            solution: #"""
            class Solution:
                def eraseOverlapIntervals(self, intervals: List[List[int]]) -> int:
                    intervals.sort(key=lambda x: x[1])  # earliest end first
                    removed = 0
                    prev_end = float("-inf")
                    for start, end in intervals:
                        if start >= prev_end:
                            prev_end = end
                        else:
                            removed += 1
                    return removed
            """#,
            time: "O(n log n)", space: "O(1)"),
    ]

    static let math: [Problem] = [
        Problem(
            id: "rotate-image", number: 48, title: "Rotate Image", difficulty: .medium, topic: .math,
            description: "Given an `n × n` matrix, rotate it **90 degrees clockwise** in place, without allocating another matrix.",
            examples: [ex("matrix = [[1,2,3],[4,5,6],[7,8,9]]", "[[7,4,1],[8,5,2],[9,6,3]]")],
            constraints: ["1 ≤ n ≤ 20", "-1000 ≤ matrix[i][j] ≤ 1000"],
            hints: ["A rotation can be decomposed into two simpler reflections.", "Try transposing, then reversing each row."],
            approach: ["**Transpose**: swap `matrix[i][j]` with `matrix[j][i]` above the diagonal.", "**Reverse** each row.", "Together, these two reflections equal a 90° clockwise rotation."],
            solution: #"""
            class Solution:
                def rotate(self, matrix: List[List[int]]) -> None:
                    n = len(matrix)
                    # 1. transpose
                    for i in range(n):
                        for j in range(i + 1, n):
                            matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]
                    # 2. reverse each row
                    for row in matrix:
                        row.reverse()
            """#,
            time: "O(n²)", space: "O(1)"),

        Problem(
            id: "happy-number", number: 202, title: "Happy Number", difficulty: .easy, topic: .math,
            description: "Replace a number by the sum of the squares of its digits, and repeat. If the process reaches `1`, the number is **happy**; otherwise it loops forever.\n\nReturn `true` if `n` is happy.",
            examples: [ex("n = 19", "true", "1² + 9² = 82 → 68 → 100 → 1"), ex("n = 2", "false")],
            constraints: ["1 ≤ n ≤ 2³¹ - 1"],
            hints: ["An unhappy number eventually repeats a value.", "Detect the repeat with a set (or fast/slow pointers)."],
            approach: ["Repeatedly compute the digit-square sum.", "Store seen numbers in a **set**; a repeat means a cycle.", "Return whether we stopped at 1."],
            solution: #"""
            class Solution:
                def isHappy(self, n: int) -> bool:
                    seen = set()
                    while n != 1 and n not in seen:
                        seen.add(n)
                        n = sum(int(d) ** 2 for d in str(n))
                    return n == 1
            """#,
            time: "O(log n)", space: "O(log n)"),
    ]

    static let bits: [Problem] = [
        Problem(
            id: "single-number", number: 136, title: "Single Number", difficulty: .easy, topic: .bitManipulation,
            description: "In a non-empty array `nums`, every element appears **twice** except one. Find that single element using linear time and constant extra space.",
            examples: [ex("nums = [2,2,1]", "1"), ex("nums = [4,1,2,1,2]", "4")],
            constraints: ["1 ≤ nums.length ≤ 3 · 10⁴", "Every element appears twice except one"],
            hints: ["What is `a ^ a`? What is `a ^ 0`?", "XOR is commutative, so order doesn't matter."],
            approach: ["XOR every number together.", "Pairs cancel out because `a ^ a = 0`.", "What's left is the single number, since `0 ^ x = x`."],
            solution: #"""
            class Solution:
                def singleNumber(self, nums: List[int]) -> int:
                    result = 0
                    for n in nums:
                        result ^= n  # pairs cancel out: a ^ a = 0
                    return result
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "counting-bits", number: 338, title: "Counting Bits", difficulty: .easy, topic: .bitManipulation,
            description: "Given an integer `n`, return an array `ans` of length `n + 1` where `ans[i]` is the number of `1` bits in the binary form of `i`.",
            examples: [ex("n = 2", "[0,1,1]"), ex("n = 5", "[0,1,1,2,1,2]")],
            constraints: ["0 ≤ n ≤ 10⁵"],
            hints: ["`i >> 1` is `i` without its last bit, and you've already computed it.", "The last bit is `i & 1`."],
            approach: ["`i` has the same bits as `i >> 1`, plus its lowest bit.", "So `ans[i] = ans[i >> 1] + (i & 1)`.", "Fill the array from 1 up to n."],
            solution: #"""
            class Solution:
                def countBits(self, n: int) -> List[int]:
                    ans = [0] * (n + 1)
                    for i in range(1, n + 1):
                        ans[i] = ans[i >> 1] + (i & 1)
                    return ans
            """#,
            time: "O(n)", space: "O(n)"),
    ]
}
