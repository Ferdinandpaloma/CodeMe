import Foundation

extension ProblemBank {
    static let arrays: [Problem] = [
        Problem(
            id: "contains-duplicate", number: 217, title: "Contains Duplicate", difficulty: .easy, topic: .arrays,
            description: "Given an integer array `nums`, return `true` if any value appears **at least twice** in the array, and `false` if every element is distinct.",
            examples: [ex("nums = [1,2,3,1]", "true", "The value 1 appears at index 0 and 3."), ex("nums = [1,2,3,4]", "false")],
            constraints: ["1 ≤ nums.length ≤ 10⁵", "-10⁹ ≤ nums[i] ≤ 10⁹"],
            hints: ["Brute force compares every pair, which is O(n²). Can you avoid repeated work?", "Which data structure answers \"have I seen this value?\" in O(1)?"],
            approach: ["Walk through the array once, keeping a **set** of values seen so far.", "If the current value is already in the set, we found a duplicate, so return `True`.", "If the loop finishes, every value was unique."],
            solution: #"""
            class Solution:
                def containsDuplicate(self, nums: List[int]) -> bool:
                    seen = set()
                    for n in nums:
                        if n in seen:
                            return True
                        seen.add(n)
                    return False
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "two-sum", number: 1, title: "Two Sum", difficulty: .easy, topic: .arrays,
            description: "Given an array of integers `nums` and an integer `target`, return the **indices** of the two numbers that add up to `target`.\n\nEach input has exactly one solution, and you may not use the same element twice.",
            examples: [ex("nums = [2,7,11,15], target = 9", "[0,1]", "nums[0] + nums[1] == 9"), ex("nums = [3,2,4], target = 6", "[1,2]")],
            constraints: ["2 ≤ nums.length ≤ 10⁴", "-10⁹ ≤ nums[i], target ≤ 10⁹", "Exactly one valid answer exists"],
            hints: ["For each number x, the partner you need is `target - x`.", "Store numbers you've already passed in a hash map from value to index."],
            approach: ["Keep a hash map from **value → index** for numbers already visited.", "For each `n`, compute `diff = target - n`.", "If `diff` is in the map, return its index and the current index; otherwise store `n`."],
            solution: #"""
            class Solution:
                def twoSum(self, nums: List[int], target: int) -> List[int]:
                    index = {}  # value -> index
                    for i, n in enumerate(nums):
                        diff = target - n
                        if diff in index:
                            return [index[diff], i]
                        index[n] = i
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "group-anagrams", number: 49, title: "Group Anagrams", difficulty: .medium, topic: .arrays,
            description: "Given an array of strings `strs`, group the **anagrams** together. You can return the groups in any order.\n\nAn anagram uses exactly the same letters as another word, rearranged.",
            examples: [ex(#"strs = ["eat","tea","tan","ate","nat","bat"]"#, #"[["bat"],["nat","tan"],["ate","eat","tea"]]"#), ex(#"strs = ["a"]"#, #"[["a"]]"#)],
            constraints: ["1 ≤ strs.length ≤ 10⁴", "0 ≤ strs[i].length ≤ 100", "Lowercase English letters only"],
            hints: ["Two words are anagrams if they have the same letter counts.", "What could you use as a hash-map key that is identical for all anagrams?"],
            approach: ["For each word, build a 26-length **letter count** array.", "Convert it to a tuple so it can be a dictionary key.", "Append the word to the list stored under that key, then return all lists."],
            solution: #"""
            class Solution:
                def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
                    groups = defaultdict(list)
                    for s in strs:
                        count = [0] * 26
                        for c in s:
                            count[ord(c) - ord("a")] += 1
                        groups[tuple(count)].append(s)
                    return list(groups.values())
            """#,
            time: "O(m · n)", space: "O(m · n)"),

        Problem(
            id: "top-k-frequent-elements", number: 347, title: "Top K Frequent Elements", difficulty: .medium, topic: .arrays,
            description: "Given an integer array `nums` and an integer `k`, return the `k` **most frequent** elements, in any order.",
            examples: [ex("nums = [1,1,1,2,2,3], k = 2", "[1,2]"), ex("nums = [1], k = 1", "[1]")],
            constraints: ["1 ≤ nums.length ≤ 10⁵", "k is in the range [1, number of unique elements]", "The answer is unique"],
            hints: ["Start by counting frequencies with a hash map.", "A frequency can never exceed `len(nums)`. Can you use that to sort in linear time?"],
            approach: ["Count every value with a `Counter`.", "**Bucket sort**: `buckets[f]` holds all values that appear `f` times.", "Walk buckets from highest frequency down, collecting values until you have `k`."],
            solution: #"""
            class Solution:
                def topKFrequent(self, nums: List[int], k: int) -> List[int]:
                    count = Counter(nums)
                    buckets = [[] for _ in range(len(nums) + 1)]
                    for n, freq in count.items():
                        buckets[freq].append(n)

                    result = []
                    for freq in range(len(buckets) - 1, 0, -1):
                        for n in buckets[freq]:
                            result.append(n)
                            if len(result) == k:
                                return result
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "longest-consecutive-sequence", number: 128, title: "Longest Consecutive Sequence", difficulty: .medium, topic: .arrays,
            description: "Given an unsorted array of integers `nums`, return the length of the longest sequence of **consecutive** integers.\n\nYour algorithm must run in O(n) time.",
            examples: [ex("nums = [100,4,200,1,3,2]", "4", "The sequence is [1, 2, 3, 4]."), ex("nums = [0,3,7,2,5,8,4,6,0,1]", "9")],
            constraints: ["0 ≤ nums.length ≤ 10⁵", "-10⁹ ≤ nums[i] ≤ 10⁹"],
            hints: ["Sorting gives O(n log n). How can a set help you avoid sorting?", "A number starts a sequence only if `n - 1` is not in the set."],
            approach: ["Put every number into a **set**.", "Only start counting from numbers where `n - 1` is missing; those are sequence starts.", "From each start, count upward while `n + length` exists. Each number is visited at most twice overall."],
            solution: #"""
            class Solution:
                def longestConsecutive(self, nums: List[int]) -> int:
                    num_set = set(nums)
                    longest = 0
                    for n in num_set:
                        if n - 1 not in num_set:  # start of a sequence
                            length = 1
                            while n + length in num_set:
                                length += 1
                            longest = max(longest, length)
                    return longest
            """#,
            time: "O(n)", space: "O(n)"),
    ]

    static let twoPointers: [Problem] = [
        Problem(
            id: "valid-palindrome", number: 125, title: "Valid Palindrome", difficulty: .easy, topic: .twoPointers,
            description: "A phrase is a **palindrome** if, after lowercasing it and removing every non-alphanumeric character, it reads the same forward and backward.\n\nGiven a string `s`, return `true` if it is a palindrome.",
            examples: [ex(#"s = "A man, a plan, a canal: Panama""#, "true", #""amanaplanacanalpanama" is a palindrome."#), ex(#"s = "race a car""#, "false")],
            constraints: ["1 ≤ s.length ≤ 2 · 10⁵", "s consists of printable ASCII characters"],
            hints: ["Building a cleaned copy works but uses O(n) space.", "Compare characters from both ends, skipping anything that isn't a letter or digit."],
            approach: ["Place `l` at the start and `r` at the end.", "Skip non-alphanumeric characters on each side.", "Compare the lowercase characters; if they differ, it's not a palindrome. Otherwise move both pointers inward."],
            solution: #"""
            class Solution:
                def isPalindrome(self, s: str) -> bool:
                    l, r = 0, len(s) - 1
                    while l < r:
                        while l < r and not s[l].isalnum():
                            l += 1
                        while l < r and not s[r].isalnum():
                            r -= 1
                        if s[l].lower() != s[r].lower():
                            return False
                        l, r = l + 1, r - 1
                    return True
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "3sum", number: 15, title: "3Sum", difficulty: .medium, topic: .twoPointers,
            description: "Given an integer array `nums`, return all unique triplets `[nums[i], nums[j], nums[k]]` where `i`, `j`, `k` are distinct and the three numbers sum to **zero**.\n\nThe answer must not contain duplicate triplets.",
            examples: [ex("nums = [-1,0,1,2,-1,-4]", "[[-1,-1,2],[-1,0,1]]"), ex("nums = [0,1,1]", "[]"), ex("nums = [0,0,0]", "[[0,0,0]]")],
            constraints: ["3 ≤ nums.length ≤ 3000", "-10⁵ ≤ nums[i] ≤ 10⁵"],
            hints: ["Fix one number, then you need a Two Sum on the rest.", "Sorting lets you use two pointers and skip duplicates easily."],
            approach: ["**Sort** the array.", "For each index `i` (skipping repeated values), run two pointers on the remainder to find pairs summing to `-nums[i]`.", "After finding a triplet, move `l` past duplicate values so each triplet is recorded once."],
            solution: #"""
            class Solution:
                def threeSum(self, nums: List[int]) -> List[List[int]]:
                    nums.sort()
                    result = []
                    for i, a in enumerate(nums):
                        if i > 0 and a == nums[i - 1]:
                            continue  # skip duplicate first numbers
                        l, r = i + 1, len(nums) - 1
                        while l < r:
                            total = a + nums[l] + nums[r]
                            if total > 0:
                                r -= 1
                            elif total < 0:
                                l += 1
                            else:
                                result.append([a, nums[l], nums[r]])
                                l += 1
                                while l < r and nums[l] == nums[l - 1]:
                                    l += 1
                    return result
            """#,
            time: "O(n²)", space: "O(1) extra"),

        Problem(
            id: "container-with-most-water", number: 11, title: "Container With Most Water", difficulty: .medium, topic: .twoPointers,
            description: "You are given an array `height` where `height[i]` is the height of a vertical line at position `i`.\n\nPick two lines that, together with the x-axis, form a container holding the **most water**. Return that maximum area.",
            examples: [ex("height = [1,8,6,2,5,4,8,3,7]", "49", "Lines at index 1 and 8: min(8, 7) × 7 = 49."), ex("height = [1,1]", "1")],
            constraints: ["2 ≤ height.length ≤ 10⁵", "0 ≤ height[i] ≤ 10⁴"],
            hints: ["Start with the widest possible container.", "The shorter line limits the area. Moving the taller one inward can never help."],
            approach: ["Start with pointers at both ends (maximum width).", "Compute the area: width × the shorter height.", "Move the pointer at the **shorter** line inward, since that's the only way the area might grow."],
            solution: #"""
            class Solution:
                def maxArea(self, height: List[int]) -> int:
                    l, r = 0, len(height) - 1
                    best = 0
                    while l < r:
                        area = (r - l) * min(height[l], height[r])
                        best = max(best, area)
                        if height[l] < height[r]:
                            l += 1
                        else:
                            r -= 1
                    return best
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "trapping-rain-water", number: 42, title: "Trapping Rain Water", difficulty: .hard, topic: .twoPointers,
            description: "Given `n` non-negative integers representing an elevation map where each bar has width 1, compute how much **water** it can trap after raining.",
            examples: [ex("height = [0,1,0,2,1,0,1,3,2,1,2,1]", "6"), ex("height = [4,2,0,3,2,5]", "9")],
            constraints: ["1 ≤ n ≤ 2 · 10⁴", "0 ≤ height[i] ≤ 10⁵"],
            hints: ["Water above bar i = min(tallest bar to its left, tallest bar to its right) - height[i].", "If you know the left max is smaller than the right max, the left side is the bottleneck."],
            approach: ["Water at each position is bounded by `min(left_max, right_max)`.", "Keep two pointers and running maxima from each side.", "Advance the side with the **smaller max**: its water level is already fully determined, so add `max - height` there."],
            solution: #"""
            class Solution:
                def trap(self, height: List[int]) -> int:
                    l, r = 0, len(height) - 1
                    left_max, right_max = height[l], height[r]
                    water = 0
                    while l < r:
                        if left_max < right_max:
                            l += 1
                            left_max = max(left_max, height[l])
                            water += left_max - height[l]
                        else:
                            r -= 1
                            right_max = max(right_max, height[r])
                            water += right_max - height[r]
                    return water
            """#,
            time: "O(n)", space: "O(1)"),
    ]

    static let slidingWindow: [Problem] = [
        Problem(
            id: "best-time-to-buy-and-sell-stock", number: 121, title: "Best Time to Buy and Sell Stock", difficulty: .easy, topic: .slidingWindow,
            description: "You are given an array `prices` where `prices[i]` is a stock's price on day `i`.\n\nChoose one day to buy and a **later** day to sell. Return the maximum profit, or `0` if no profit is possible.",
            examples: [ex("prices = [7,1,5,3,6,4]", "5", "Buy on day 1 (price 1), sell on day 4 (price 6)."), ex("prices = [7,6,4,3,1]", "0")],
            constraints: ["1 ≤ prices.length ≤ 10⁵", "0 ≤ prices[i] ≤ 10⁴"],
            hints: ["For each selling day, which buying day is best?", "Track the lowest price seen so far."],
            approach: ["Scan prices left to right, tracking the **lowest price** so far (the best buy day).", "At each day, the best sale is `price - lowest`.", "Keep the maximum of those profits."],
            solution: #"""
            class Solution:
                def maxProfit(self, prices: List[int]) -> int:
                    lowest = prices[0]
                    profit = 0
                    for price in prices:
                        lowest = min(lowest, price)
                        profit = max(profit, price - lowest)
                    return profit
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "longest-substring-without-repeating-characters", number: 3, title: "Longest Substring Without Repeating Characters", difficulty: .medium, topic: .slidingWindow,
            description: "Given a string `s`, find the length of the longest **substring** that contains no repeated characters.",
            examples: [ex(#"s = "abcabcbb""#, "3", #"The answer is "abc"."#), ex(#"s = "bbbbb""#, "1"), ex(#"s = "pwwkew""#, "3", #""wke" is the longest. "pwke" is a subsequence, not a substring."#)],
            constraints: ["0 ≤ s.length ≤ 5 · 10⁴", "s contains letters, digits, symbols and spaces"],
            hints: ["Maintain a window that never contains a duplicate.", "When the new character is already in the window, shrink from the left until it isn't."],
            approach: ["Expand the window with pointer `r` one character at a time.", "If `s[r]` is already in the window's set, remove characters from the left until it's gone.", "Record the window size `r - l + 1` after each step."],
            solution: #"""
            class Solution:
                def lengthOfLongestSubstring(self, s: str) -> int:
                    window = set()
                    l = 0
                    best = 0
                    for r in range(len(s)):
                        while s[r] in window:
                            window.remove(s[l])
                            l += 1
                        window.add(s[r])
                        best = max(best, r - l + 1)
                    return best
            """#,
            time: "O(n)", space: "O(min(n, alphabet))"),

        Problem(
            id: "longest-repeating-character-replacement", number: 424, title: "Longest Repeating Character Replacement", difficulty: .medium, topic: .slidingWindow,
            description: "You are given a string `s` of uppercase letters and an integer `k`. You may change any character to any other uppercase letter at most `k` times.\n\nReturn the length of the longest substring containing a **single repeated letter** that you can get.",
            examples: [ex(#"s = "ABAB", k = 2"#, "4", "Replace the two A's with B's (or vice versa)."), ex(#"s = "AABABBA", k = 1"#, "4")],
            constraints: ["1 ≤ s.length ≤ 10⁵", "0 ≤ k ≤ s.length"],
            hints: ["In a window, how many characters need replacing?", "Replacements needed = window length - count of the most frequent character."],
            approach: ["Grow a window and count characters inside it.", "Track `max_freq`, the highest count of any single character.", "If `window_size - max_freq > k`, the window is invalid, so shrink it from the left."],
            solution: #"""
            class Solution:
                def characterReplacement(self, s: str, k: int) -> int:
                    count = {}
                    l = 0
                    max_freq = 0
                    best = 0
                    for r in range(len(s)):
                        count[s[r]] = count.get(s[r], 0) + 1
                        max_freq = max(max_freq, count[s[r]])
                        # replacements needed = window size - most frequent char
                        while (r - l + 1) - max_freq > k:
                            count[s[l]] -= 1
                            l += 1
                        best = max(best, r - l + 1)
                    return best
            """#,
            time: "O(n)", space: "O(26)"),

        Problem(
            id: "minimum-window-substring", number: 76, title: "Minimum Window Substring", difficulty: .hard, topic: .slidingWindow,
            description: "Given strings `s` and `t`, return the **shortest substring** of `s` that contains every character of `t` (including duplicates). If none exists, return the empty string.",
            examples: [ex(#"s = "ADOBECODEBANC", t = "ABC""#, #""BANC""#), ex(#"s = "a", t = "a""#, #""a""#), ex(#"s = "a", t = "aa""#, #""""#)],
            constraints: ["1 ≤ s.length, t.length ≤ 10⁵", "Upper and lowercase English letters"],
            hints: ["Expand the window until it's valid, then shrink it as much as possible.", "Instead of comparing whole maps each step, track how many characters are fully satisfied."],
            approach: ["Count what you **need** from `t`.", "Expand `r`; when a character's count in the window reaches what's needed, increment `have`.", "While `have == required`, record the window if it's the smallest, then shrink from the left, updating `have`."],
            solution: #"""
            class Solution:
                def minWindow(self, s: str, t: str) -> str:
                    need = Counter(t)
                    window = {}
                    have, required = 0, len(need)
                    best, best_len = (-1, -1), float("inf")
                    l = 0
                    for r, c in enumerate(s):
                        window[c] = window.get(c, 0) + 1
                        if c in need and window[c] == need[c]:
                            have += 1
                        while have == required:
                            if r - l + 1 < best_len:
                                best, best_len = (l, r), r - l + 1
                            window[s[l]] -= 1
                            if s[l] in need and window[s[l]] < need[s[l]]:
                                have -= 1
                            l += 1
                    l, r = best
                    return s[l : r + 1] if best_len != float("inf") else ""
            """#,
            time: "O(n + m)", space: "O(alphabet)"),
    ]

    static let stack: [Problem] = [
        Problem(
            id: "valid-parentheses", number: 20, title: "Valid Parentheses", difficulty: .easy, topic: .stack,
            description: "Given a string `s` containing only `(`, `)`, `{`, `}`, `[` and `]`, determine whether it is **valid**:\n\n• Open brackets are closed by the same type.\n• Open brackets are closed in the correct order.\n• Every close bracket has a matching open bracket.",
            examples: [ex(#"s = "()[]{}""#, "true"), ex(#"s = "(]""#, "false"), ex(#"s = "([])""#, "true")],
            constraints: ["1 ≤ s.length ≤ 10⁴", "s consists of brackets only"],
            hints: ["The most recently opened bracket must close first.", "What data structure is last-in, first-out?"],
            approach: ["Push every opening bracket onto a **stack**.", "For a closing bracket, the top of the stack must be its matching opener; pop it.", "At the end the stack must be empty."],
            solution: #"""
            class Solution:
                def isValid(self, s: str) -> bool:
                    pairs = {")": "(", "]": "[", "}": "{"}
                    stack = []
                    for c in s:
                        if c in pairs:
                            if not stack or stack[-1] != pairs[c]:
                                return False
                            stack.pop()
                        else:
                            stack.append(c)
                    return not stack
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "min-stack", number: 155, title: "Min Stack", difficulty: .medium, topic: .stack,
            description: "Design a stack that supports `push`, `pop`, `top`, and retrieving the **minimum** element, all in O(1) time.",
            examples: [ex(#"["MinStack","push","push","push","getMin","pop","top","getMin"]"# + "\n" + "[[],[-2],[0],[-3],[],[],[],[]]", "[null,null,null,null,-3,null,0,-2]")],
            constraints: ["-2³¹ ≤ val ≤ 2³¹ - 1", "pop, top and getMin are only called on non-empty stacks"],
            hints: ["A single variable for the min breaks when you pop the min.", "What if every stack level remembered the minimum at that point?"],
            approach: ["Keep a second stack, `min_stack`, in sync with the main one.", "On push, store `min(val, current_min)` on `min_stack`.", "Pop both stacks together; the top of `min_stack` is always the current minimum."],
            solution: #"""
            class MinStack:
                def __init__(self):
                    self.stack = []
                    self.min_stack = []

                def push(self, val: int) -> None:
                    self.stack.append(val)
                    current_min = self.min_stack[-1] if self.min_stack else val
                    self.min_stack.append(min(val, current_min))

                def pop(self) -> None:
                    self.stack.pop()
                    self.min_stack.pop()

                def top(self) -> int:
                    return self.stack[-1]

                def getMin(self) -> int:
                    return self.min_stack[-1]
            """#,
            time: "O(1) per operation", space: "O(n)"),

        Problem(
            id: "daily-temperatures", number: 739, title: "Daily Temperatures", difficulty: .medium, topic: .stack,
            description: "Given an array `temperatures`, return an array `answer` where `answer[i]` is the number of days after day `i` until a **warmer** temperature. If there is no warmer day, use `0`.",
            examples: [ex("temperatures = [73,74,75,71,69,72,76,73]", "[1,1,4,2,1,1,0,0]"), ex("temperatures = [30,40,50,60]", "[1,1,1,0]")],
            constraints: ["1 ≤ temperatures.length ≤ 10⁵", "30 ≤ temperatures[i] ≤ 100"],
            hints: ["This is a \"next greater element\" problem.", "Keep the indices of days still waiting for a warmer day on a stack."],
            approach: ["Maintain a **monotonic decreasing stack** of indices.", "When today is warmer than the day on top of the stack, pop it and record `i - j`.", "Push today's index; anything left on the stack never finds a warmer day."],
            solution: #"""
            class Solution:
                def dailyTemperatures(self, temperatures: List[int]) -> List[int]:
                    answer = [0] * len(temperatures)
                    stack = []  # indices with decreasing temperatures
                    for i, t in enumerate(temperatures):
                        while stack and temperatures[stack[-1]] < t:
                            j = stack.pop()
                            answer[j] = i - j
                        stack.append(i)
                    return answer
            """#,
            time: "O(n)", space: "O(n)"),
    ]
}
