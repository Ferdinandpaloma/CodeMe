import Foundation

/// Second batch of NeetCode 150 problems, across every topic.
extension ProblemBank {
    static let extra: [Problem] = extraArrays + extraStackSearch + extraLinkedTrees + extraSearchGraphs + extraDP + extraMisc

    // MARK: Arrays, two pointers, sliding window

    private static let extraArrays: [Problem] = [
        Problem(
            id: "valid-anagram", number: 242, title: "Valid Anagram", difficulty: .easy, topic: .arrays,
            description: "Given two strings `s` and `t`, return `true` if `t` is an **anagram** of `s`, and `false` otherwise.",
            examples: [ex(#"s = "anagram", t = "nagaram""#, "true"), ex(#"s = "rat", t = "car""#, "false")],
            constraints: ["1 ≤ s.length, t.length ≤ 5 · 10⁴", "Lowercase English letters only"],
            hints: ["Anagrams have exactly the same letter counts.", "Count up for letters of `s` and down for letters of `t`. What should every count end at?"],
            approach: ["If the lengths differ, they can't be anagrams.", "Walk both strings together: **+1** for each letter in `s`, **-1** for each letter in `t`.", "They're anagrams exactly when every count ends at zero."],
            solution: #"""
            class Solution:
                def isAnagram(self, s: str, t: str) -> bool:
                    if len(s) != len(t):
                        return False
                    count = {}
                    for a, b in zip(s, t):
                        count[a] = count.get(a, 0) + 1
                        count[b] = count.get(b, 0) - 1
                    return all(v == 0 for v in count.values())
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "product-of-array-except-self", number: 238, title: "Product of Array Except Self", difficulty: .medium, topic: .arrays,
            description: "Given an integer array `nums`, return an array `answer` where `answer[i]` is the product of every element of `nums` **except** `nums[i]`.\n\nSolve it in O(n) time **without** using division.",
            examples: [ex("nums = [1,2,3,4]", "[24,12,8,6]"), ex("nums = [-1,1,0,-3,3]", "[0,0,9,0,0]")],
            constraints: ["2 ≤ nums.length ≤ 10⁵", "-30 ≤ nums[i] ≤ 30", "The product of any prefix or suffix fits in a 32-bit integer"],
            hints: ["`answer[i]` = (product of everything left of i) × (product of everything right of i).", "Compute the left products in one pass and multiply in the right products in a second, backward pass."],
            approach: ["First pass, left to right: store the **prefix product** before each index in `answer`.", "Second pass, right to left: multiply each `answer[i]` by the running **suffix product**.", "The output array doesn't count as extra space, so this is O(1) extra memory."],
            solution: #"""
            class Solution:
                def productExceptSelf(self, nums: List[int]) -> List[int]:
                    n = len(nums)
                    answer = [1] * n
                    prefix = 1
                    for i in range(n):
                        answer[i] = prefix
                        prefix *= nums[i]
                    suffix = 1
                    for i in range(n - 1, -1, -1):
                        answer[i] *= suffix
                        suffix *= nums[i]
                    return answer
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "valid-sudoku", number: 36, title: "Valid Sudoku", difficulty: .medium, topic: .arrays,
            description: "Determine whether a 9 × 9 Sudoku board is **valid**. Only the filled cells need to be checked:\n\n• Each row contains the digits 1–9 at most once.\n• Each column contains the digits 1–9 at most once.\n• Each of the nine 3 × 3 boxes contains the digits 1–9 at most once.\n\nEmpty cells are `\".\"`.",
            examples: [ex("board = a partially filled valid board", "true"), ex("board = the same board with two 8s in the top-left box", "false")],
            constraints: ["board.length == 9", "board[i].length == 9", "board[i][j] is a digit 1-9 or '.'"],
            hints: ["Keep a set of seen digits for every row, every column and every box.", "Cell (r, c) belongs to box `(r // 3, c // 3)`."],
            approach: ["Create a set per row, per column and per 3 × 3 box (keyed by `(r // 3, c // 3)`).", "Scan every filled cell. If its digit is already in its row, column or box set, the board is invalid.", "Otherwise record the digit in all three sets."],
            solution: #"""
            class Solution:
                def isValidSudoku(self, board: List[List[str]]) -> bool:
                    rows = defaultdict(set)
                    cols = defaultdict(set)
                    boxes = defaultdict(set)  # key: (r // 3, c // 3)
                    for r in range(9):
                        for c in range(9):
                            d = board[r][c]
                            if d == ".":
                                continue
                            box = (r // 3, c // 3)
                            if d in rows[r] or d in cols[c] or d in boxes[box]:
                                return False
                            rows[r].add(d)
                            cols[c].add(d)
                            boxes[box].add(d)
                    return True
            """#,
            time: "O(1)", space: "O(1)"),

        Problem(
            id: "two-sum-ii-input-array-is-sorted", number: 167, title: "Two Sum II", difficulty: .medium, topic: .twoPointers,
            description: "Given a **1-indexed** array `numbers` sorted in non-decreasing order, find two numbers that add up to `target`. Return their indices `[index1, index2]` (1-indexed).\n\nUse only **constant** extra space.",
            examples: [ex("numbers = [2,7,11,15], target = 9", "[1,2]"), ex("numbers = [2,3,4], target = 6", "[1,3]")],
            constraints: ["2 ≤ numbers.length ≤ 3 · 10⁴", "numbers is sorted in non-decreasing order", "Exactly one solution exists"],
            hints: ["The array is sorted. What happens to the sum if you move the right pointer left?", "Too big: shrink from the right. Too small: grow from the left."],
            approach: ["Start with `l` at the smallest value and `r` at the largest.", "If the sum is too **big**, move `r` left to make it smaller. If it's too **small**, move `l` right.", "When the sum matches, return the 1-based indices."],
            solution: #"""
            class Solution:
                def twoSum(self, numbers: List[int], target: int) -> List[int]:
                    l, r = 0, len(numbers) - 1
                    while l < r:
                        total = numbers[l] + numbers[r]
                        if total > target:
                            r -= 1
                        elif total < target:
                            l += 1
                        else:
                            return [l + 1, r + 1]
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "permutation-in-string", number: 567, title: "Permutation in String", difficulty: .medium, topic: .slidingWindow,
            description: "Given two strings `s1` and `s2`, return `true` if `s2` contains a **permutation** of `s1` as a substring.",
            examples: [ex(#"s1 = "ab", s2 = "eidbaooo""#, "true", #"s2 contains "ba"."#), ex(#"s1 = "ab", s2 = "eidboaoo""#, "false")],
            constraints: ["1 ≤ s1.length, s2.length ≤ 10⁴", "Lowercase English letters only"],
            hints: ["A permutation of `s1` has exactly the same letter counts as `s1`.", "Slide a window of length `len(s1)` across `s2`, updating counts as it moves."],
            approach: ["Count the letters of `s1`.", "Keep a **fixed-size window** of `len(s1)` characters in `s2` with its own counts.", "Slide one step at a time: add the new right character, remove the old left one, and compare the counts."],
            solution: #"""
            class Solution:
                def checkInclusion(self, s1: str, s2: str) -> bool:
                    if len(s1) > len(s2):
                        return False
                    need = Counter(s1)
                    window = Counter(s2[:len(s1)])
                    if window == need:
                        return True
                    for r in range(len(s1), len(s2)):
                        window[s2[r]] += 1
                        left = s2[r - len(s1)]
                        window[left] -= 1
                        if window[left] == 0:
                            del window[left]
                        if window == need:
                            return True
                    return False
            """#,
            time: "O(n)", space: "O(1)"),
    ]

    // MARK: Stack and binary search

    private static let extraStackSearch: [Problem] = [
        Problem(
            id: "evaluate-reverse-polish-notation", number: 150, title: "Evaluate Reverse Polish Notation", difficulty: .medium, topic: .stack,
            description: "Evaluate an arithmetic expression written in **Reverse Polish Notation**, where every operator comes after its two operands.\n\nValid operators are `+`, `-`, `*` and `/`. Division truncates toward zero.",
            examples: [ex(#"tokens = ["2","1","+","3","*"]"#, "9", "((2 + 1) * 3) = 9"), ex(#"tokens = ["4","13","5","/","+"]"#, "6", "(4 + (13 / 5)) = 6")],
            constraints: ["1 ≤ tokens.length ≤ 10⁴", "The expression is always valid"],
            hints: ["When you see an operator, which two numbers does it apply to?", "Push numbers on a stack. An operator pops two, combines them and pushes the result."],
            approach: ["Scan the tokens left to right with a **stack** of numbers.", "A number is pushed. An operator pops `b` then `a` (order matters for `-` and `/`) and pushes `a op b`.", "The single value left on the stack is the answer."],
            solution: #"""
            class Solution:
                def evalRPN(self, tokens: List[str]) -> int:
                    stack = []
                    for t in tokens:
                        if t in "+-*/":
                            b, a = stack.pop(), stack.pop()
                            if t == "+":
                                stack.append(a + b)
                            elif t == "-":
                                stack.append(a - b)
                            elif t == "*":
                                stack.append(a * b)
                            else:
                                stack.append(int(a / b))  # truncate toward zero
                        else:
                            stack.append(int(t))
                    return stack[0]
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "generate-parentheses", number: 22, title: "Generate Parentheses", difficulty: .medium, topic: .stack,
            description: "Given `n` pairs of parentheses, generate every combination of **well-formed** parentheses.",
            examples: [ex("n = 3", #"["((()))","(()())","(())()","()(())","()()()"]"#), ex("n = 1", #"["()"]"#)],
            constraints: ["1 ≤ n ≤ 8"],
            hints: ["You may add `(` as long as you've used fewer than n of them.", "You may add `)` only while there are more opens than closes so far."],
            approach: ["Build strings one character at a time, tracking how many `(` and `)` are used.", "Add `(` if `open < n`. Add `)` if `close < open`, which keeps the prefix valid.", "When the string has length `2n`, it's a complete valid answer."],
            solution: #"""
            class Solution:
                def generateParenthesis(self, n: int) -> List[str]:
                    result = []

                    def backtrack(path, open_count, close_count):
                        if len(path) == 2 * n:
                            result.append("".join(path))
                            return
                        if open_count < n:
                            path.append("(")
                            backtrack(path, open_count + 1, close_count)
                            path.pop()
                        if close_count < open_count:
                            path.append(")")
                            backtrack(path, open_count, close_count + 1)
                            path.pop()

                    backtrack([], 0, 0)
                    return result
            """#,
            time: "O(4ⁿ / √n)", space: "O(n)"),

        Problem(
            id: "car-fleet", number: 853, title: "Car Fleet", difficulty: .medium, topic: .stack,
            description: "`n` cars drive toward `target` on a one-lane road. Car `i` starts at `position[i]` with speed `speed[i]`. A car can't pass the car ahead; when it catches up, they drive together as one **fleet**.\n\nReturn the number of fleets that arrive at the target.",
            examples: [ex("target = 12, position = [10,8,0,5,3], speed = [2,4,1,1,3]", "3"), ex("target = 10, position = [3], speed = [3]", "1")],
            constraints: ["1 ≤ n ≤ 10⁵", "0 < target ≤ 10⁶", "All positions are unique"],
            hints: ["Work out each car's arrival time if the road were empty.", "Process cars from closest to the target. A car that would arrive no later than the fleet ahead joins it."],
            approach: ["Sort cars by position, **closest to the target first**.", "Compute each car's solo arrival time `(target - p) / s`.", "If a car would arrive later than the fleet in front, it starts a **new fleet**; otherwise it catches up and merges."],
            solution: #"""
            class Solution:
                def carFleet(self, target: int, position: List[int], speed: List[int]) -> int:
                    cars = sorted(zip(position, speed), reverse=True)
                    fleets = []  # arrival times of fleet leaders
                    for p, s in cars:
                        time = (target - p) / s
                        if not fleets or time > fleets[-1]:
                            fleets.append(time)
                    return len(fleets)
            """#,
            time: "O(n log n)", space: "O(n)"),

        Problem(
            id: "largest-rectangle-in-histogram", number: 84, title: "Largest Rectangle in Histogram", difficulty: .hard, topic: .stack,
            description: "Given an array `heights` of bar heights in a histogram (each bar has width 1), return the area of the **largest rectangle** in the histogram.",
            examples: [ex("heights = [2,1,5,6,2,3]", "10", "Bars 5 and 6 form a 2 × 5 rectangle."), ex("heights = [2,4]", "4")],
            constraints: ["1 ≤ heights.length ≤ 10⁵", "0 ≤ heights[i] ≤ 10⁴"],
            hints: ["A rectangle of height h extends left and right until it hits a shorter bar.", "Keep a stack of bars with increasing heights. When a shorter bar arrives, the taller bars on the stack can't extend further right."],
            approach: ["Keep a **monotonic increasing stack** of `(start index, height)`.", "When a shorter bar arrives, pop taller bars and score each: `height × (i - start)`. The new bar can extend back to the earliest popped start.", "Bars left on the stack at the end extend all the way to the right edge."],
            solution: #"""
            class Solution:
                def largestRectangleArea(self, heights: List[int]) -> int:
                    stack = []  # (start index, height), heights increasing
                    best = 0
                    for i, h in enumerate(heights):
                        start = i
                        while stack and stack[-1][1] > h:
                            index, height = stack.pop()
                            best = max(best, height * (i - index))
                            start = index
                        stack.append((start, h))
                    for index, height in stack:
                        best = max(best, height * (len(heights) - index))
                    return best
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "search-a-2d-matrix", number: 74, title: "Search a 2D Matrix", difficulty: .medium, topic: .binarySearch,
            description: "Each row of an `m × n` matrix is sorted, and the first number of each row is greater than the last number of the previous row.\n\nReturn `true` if `target` is in the matrix. Aim for O(log(m · n)).",
            examples: [ex("matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 3", "true"), ex("same matrix, target = 13", "false")],
            constraints: ["1 ≤ m, n ≤ 100", "-10⁴ ≤ matrix[i][j], target ≤ 10⁴"],
            hints: ["Read row by row, the whole matrix is one long sorted list.", "Index k of that list lives at `matrix[k // n][k % n]`."],
            approach: ["Treat the matrix as a **flattened sorted array** of length `m · n`.", "Binary search on the flat index, converting with `row = mid // cols`, `col = mid % cols`.", "Move `l` or `r` as in a normal binary search."],
            solution: #"""
            class Solution:
                def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
                    rows, cols = len(matrix), len(matrix[0])
                    l, r = 0, rows * cols - 1
                    while l <= r:
                        mid = (l + r) // 2
                        value = matrix[mid // cols][mid % cols]
                        if value == target:
                            return True
                        if value < target:
                            l = mid + 1
                        else:
                            r = mid - 1
                    return False
            """#,
            time: "O(log(m · n))", space: "O(1)"),

        Problem(
            id: "find-minimum-in-rotated-sorted-array", number: 153, title: "Find Minimum in Rotated Sorted Array", difficulty: .medium, topic: .binarySearch,
            description: "A sorted array of **unique** numbers was rotated some number of times, e.g. `[0,1,2,4,5,6,7]` might become `[4,5,6,7,0,1,2]`.\n\nReturn the minimum element in O(log n) time.",
            examples: [ex("nums = [3,4,5,1,2]", "1"), ex("nums = [4,5,6,7,0,1,2]", "0"), ex("nums = [11,13,15,17]", "11")],
            constraints: ["1 ≤ nums.length ≤ 5000", "All values are unique", "nums is sorted and rotated 1 to n times"],
            hints: ["Compare `nums[mid]` with `nums[r]`.", "If `nums[mid] > nums[r]`, the drop (and the minimum) is to the right of mid."],
            approach: ["Binary search with `l < r`.", "If `nums[mid] > nums[r]`, the rotation point is right of mid, so `l = mid + 1`.", "Otherwise mid..r is sorted and mid itself might be the minimum, so `r = mid`. When `l == r`, that's the minimum."],
            solution: #"""
            class Solution:
                def findMin(self, nums: List[int]) -> int:
                    l, r = 0, len(nums) - 1
                    while l < r:
                        mid = (l + r) // 2
                        if nums[mid] > nums[r]:
                            l = mid + 1  # minimum is right of mid
                        else:
                            r = mid      # mid could be the minimum
                    return nums[l]
            """#,
            time: "O(log n)", space: "O(1)"),

        Problem(
            id: "time-based-key-value-store", number: 981, title: "Time Based Key-Value Store", difficulty: .medium, topic: .binarySearch,
            description: "Design a key-value store that keeps multiple values per key at different timestamps.\n\n• `set(key, value, timestamp)` stores the value.\n• `get(key, timestamp)` returns the value with the **largest timestamp ≤ timestamp**, or `\"\"` if there is none.\n\nTimestamps passed to `set` are strictly increasing.",
            examples: [ex(#"set("foo","bar",1), get("foo",1), get("foo",3), set("foo","bar2",4), get("foo",4), get("foo",5)"#, #"["bar","bar",null,"bar2","bar2"]"#)],
            constraints: ["1 ≤ timestamp ≤ 10⁷", "Timestamps in set are strictly increasing", "At most 2 · 10⁵ calls"],
            hints: ["Because timestamps only increase, each key's list of values is already sorted by time.", "Binary search for the rightmost timestamp that is ≤ the query."],
            approach: ["Map each key to a list of `(timestamp, value)` pairs, appended in increasing order.", "For `get`, **binary search** the list for the last timestamp ≤ the query.", "Remember the best candidate each time you move right."],
            solution: #"""
            class TimeMap:
                def __init__(self):
                    self.store = defaultdict(list)  # key -> [(timestamp, value)]

                def set(self, key: str, value: str, timestamp: int) -> None:
                    self.store[key].append((timestamp, value))

                def get(self, key: str, timestamp: int) -> str:
                    values = self.store[key]
                    l, r = 0, len(values) - 1
                    result = ""
                    while l <= r:
                        mid = (l + r) // 2
                        if values[mid][0] <= timestamp:
                            result = values[mid][1]
                            l = mid + 1
                        else:
                            r = mid - 1
                    return result
            """#,
            time: "O(log n)", space: "O(n)"),
    ]

    // MARK: Linked list and trees

    private static let extraLinkedTrees: [Problem] = [
        Problem(
            id: "remove-nth-node-from-end-of-list", number: 19, title: "Remove Nth Node From End of List", difficulty: .medium, topic: .linkedList,
            description: "Given the `head` of a linked list, remove the `n`th node **from the end** and return the head.",
            examples: [ex("head = [1,2,3,4,5], n = 2", "[1,2,3,5]"), ex("head = [1], n = 1", "[]")],
            constraints: ["1 ≤ list length ≤ 30", "1 ≤ n ≤ list length"],
            hints: ["Can you do it in one pass? Use two pointers with a gap of n between them.", "A dummy node before the head handles removing the head itself."],
            approach: ["Put a **dummy** node before the head.", "Move `right` n steps ahead, so `left` and `right` are n nodes apart.", "Advance both until `right` falls off the end. Now `left.next` is the node to remove."],
            solution: listNodeHeader + #"""
            class Solution:
                def removeNthFromEnd(self, head: Optional[ListNode], n: int) -> Optional[ListNode]:
                    dummy = ListNode(0, head)
                    left, right = dummy, head
                    for _ in range(n):
                        right = right.next
                    while right:
                        left, right = left.next, right.next
                    left.next = left.next.next
                    return dummy.next
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "reorder-list", number: 143, title: "Reorder List", difficulty: .medium, topic: .linkedList,
            description: "Reorder the list `L0 → L1 → … → Ln-1 → Ln` into `L0 → Ln → L1 → Ln-1 → L2 → Ln-2 → …`, in place.",
            examples: [ex("head = [1,2,3,4]", "[1,4,2,3]"), ex("head = [1,2,3,4,5]", "[1,5,2,4,3]")],
            constraints: ["1 ≤ list length ≤ 5 · 10⁴", "1 ≤ Node.val ≤ 1000"],
            hints: ["The answer alternates between the first half and the reversed second half.", "Three classic steps: find the middle, reverse a list, merge two lists."],
            approach: ["Find the middle with **slow/fast pointers**, then cut the list in two.", "**Reverse** the second half.", "**Merge** the halves by alternating nodes."],
            solution: listNodeHeader + #"""
            class Solution:
                def reorderList(self, head: Optional[ListNode]) -> None:
                    # 1. find the middle
                    slow, fast = head, head.next
                    while fast and fast.next:
                        slow, fast = slow.next, fast.next.next
                    # 2. reverse the second half
                    second, slow.next = slow.next, None
                    prev = None
                    while second:
                        nxt = second.next
                        second.next = prev
                        prev, second = second, nxt
                    # 3. merge the two halves
                    first, second = head, prev
                    while second:
                        tmp1, tmp2 = first.next, second.next
                        first.next = second
                        second.next = tmp1
                        first, second = tmp1, tmp2
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "add-two-numbers", number: 2, title: "Add Two Numbers", difficulty: .medium, topic: .linkedList,
            description: "Two non-negative integers are stored as linked lists with their digits in **reverse order** (ones digit first). Add them and return the sum as a linked list in the same format.",
            examples: [ex("l1 = [2,4,3], l2 = [5,6,4]", "[7,0,8]", "342 + 465 = 807"), ex("l1 = [9,9,9], l2 = [1]", "[0,0,0,1]")],
            constraints: ["1 ≤ list length ≤ 100", "0 ≤ Node.val ≤ 9", "No leading zeros"],
            hints: ["Reverse order is a gift: it's how you add numbers by hand, ones digit first.", "Keep going while either list has digits **or** there's a carry left."],
            approach: ["Walk both lists together, adding the digits plus the **carry**.", "`carry, digit = divmod(total, 10)`, then append `digit` to the result.", "Continue until both lists are empty and the carry is 0."],
            solution: listNodeHeader + #"""
            class Solution:
                def addTwoNumbers(self, l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
                    dummy = tail = ListNode()
                    carry = 0
                    while l1 or l2 or carry:
                        total = carry
                        if l1:
                            total += l1.val
                            l1 = l1.next
                        if l2:
                            total += l2.val
                            l2 = l2.next
                        carry, digit = divmod(total, 10)
                        tail.next = ListNode(digit)
                        tail = tail.next
                    return dummy.next
            """#,
            time: "O(max(m, n))", space: "O(1)"),

        Problem(
            id: "find-the-duplicate-number", number: 287, title: "Find the Duplicate Number", difficulty: .medium, topic: .linkedList,
            description: "An array `nums` holds `n + 1` integers, each in the range `[1, n]`. Exactly one number is repeated (possibly many times). Return it **without modifying** the array and using only O(1) extra space.",
            examples: [ex("nums = [1,3,4,2,2]", "2"), ex("nums = [3,1,3,4,2]", "3")],
            constraints: ["1 ≤ n ≤ 10⁵", "nums.length == n + 1", "1 ≤ nums[i] ≤ n"],
            hints: ["Treat each value as a pointer: index i points to index `nums[i]`.", "Two indices point at the duplicate, so the pointers form a cycle. Its entrance is the answer."],
            approach: ["Follow `i → nums[i]` like a linked list. The duplicate value is where a **cycle begins**.", "Run **Floyd's** slow/fast pointers until they meet inside the cycle.", "Start a second slow pointer at 0. Where the two slow pointers meet is the cycle entrance, the duplicate."],
            solution: #"""
            class Solution:
                def findDuplicate(self, nums: List[int]) -> int:
                    slow = fast = 0
                    while True:
                        slow = nums[slow]
                        fast = nums[nums[fast]]
                        if slow == fast:
                            break
                    slow2 = 0
                    while slow != slow2:
                        slow = nums[slow]
                        slow2 = nums[slow2]
                    return slow
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "same-tree", number: 100, title: "Same Tree", difficulty: .easy, topic: .trees,
            description: "Given the roots of two binary trees `p` and `q`, return `true` if they are **structurally identical** with the same node values.",
            examples: [ex("p = [1,2,3], q = [1,2,3]", "true"), ex("p = [1,2], q = [1,null,2]", "false")],
            constraints: ["0 ≤ number of nodes ≤ 100", "-10⁴ ≤ Node.val ≤ 10⁴"],
            hints: ["Two trees are equal if their roots match and both pairs of subtrees are equal.", "Handle the empty cases first."],
            approach: ["If both nodes are empty, they match.", "If only one is empty, or the values differ, they don't.", "Otherwise **recurse** on the left pair and the right pair."],
            solution: treeNodeHeader + #"""
            class Solution:
                def isSameTree(self, p: Optional[TreeNode], q: Optional[TreeNode]) -> bool:
                    if not p and not q:
                        return True
                    if not p or not q or p.val != q.val:
                        return False
                    return self.isSameTree(p.left, q.left) and self.isSameTree(p.right, q.right)
            """#,
            time: "O(n)", space: "O(h)"),

        Problem(
            id: "diameter-of-binary-tree", number: 543, title: "Diameter of Binary Tree", difficulty: .easy, topic: .trees,
            description: "Return the length of the **diameter** of a binary tree: the number of edges on the longest path between any two nodes. The path may or may not pass through the root.",
            examples: [ex("root = [1,2,3,4,5]", "3", "The path [4,2,1,3] or [5,2,1,3]."), ex("root = [1,2]", "1")],
            constraints: ["1 ≤ number of nodes ≤ 10⁴", "-100 ≤ Node.val ≤ 100"],
            hints: ["The longest path through a node uses the heights of its left and right subtrees.", "Compute heights bottom-up and update a global best at every node."],
            approach: ["A DFS returns each subtree's **height**.", "At every node, the longest path bending there is `left + right` edges. Update `best`.", "Return `1 + max(left, right)` to the parent."],
            solution: treeNodeHeader + #"""
            class Solution:
                def diameterOfBinaryTree(self, root: Optional[TreeNode]) -> int:
                    best = 0

                    def height(node):
                        nonlocal best
                        if not node:
                            return 0
                        left, right = height(node.left), height(node.right)
                        best = max(best, left + right)
                        return 1 + max(left, right)

                    height(root)
                    return best
            """#,
            time: "O(n)", space: "O(h)"),

        Problem(
            id: "lowest-common-ancestor-of-a-binary-search-tree", number: 235, title: "Lowest Common Ancestor of a BST", difficulty: .medium, topic: .trees,
            description: "Given a **binary search tree** and two of its nodes `p` and `q`, return their lowest common ancestor: the deepest node that has both as descendants (a node counts as its own descendant).",
            examples: [ex("root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8", "6"), ex("same tree, p = 2, q = 4", "2")],
            constraints: ["2 ≤ number of nodes ≤ 10⁵", "All values are unique", "p and q exist in the tree"],
            hints: ["The BST ordering tells you which side each node is on.", "If p and q are on different sides of a node (or one is the node), that node is the answer."],
            approach: ["Start at the root.", "If both values are **smaller**, the answer is in the left subtree. If both are **larger**, go right.", "Otherwise the paths to p and q split here, so this node is the LCA."],
            solution: treeNodeHeader + #"""
            class Solution:
                def lowestCommonAncestor(self, root: TreeNode, p: TreeNode, q: TreeNode) -> TreeNode:
                    node = root
                    while node:
                        if p.val < node.val and q.val < node.val:
                            node = node.left
                        elif p.val > node.val and q.val > node.val:
                            node = node.right
                        else:
                            return node  # the paths split here
            """#,
            time: "O(h)", space: "O(1)"),

        Problem(
            id: "kth-smallest-element-in-a-bst", number: 230, title: "Kth Smallest Element in a BST", difficulty: .medium, topic: .trees,
            description: "Given the `root` of a binary search tree and an integer `k`, return the `k`th smallest value (1-indexed) in the tree.",
            examples: [ex("root = [3,1,4,null,2], k = 1", "1"), ex("root = [5,3,6,2,4,null,null,1], k = 3", "3")],
            constraints: ["1 ≤ k ≤ n ≤ 10⁴", "0 ≤ Node.val ≤ 10⁴"],
            hints: ["An in-order traversal of a BST visits values in sorted order.", "Do the traversal iteratively and stop at the kth node."],
            approach: ["**In-order traversal** (left, node, right) yields BST values in ascending order.", "Use an explicit stack: go left as far as possible, pop, then go right.", "Count the pops; the kth one is the answer."],
            solution: treeNodeHeader + #"""
            class Solution:
                def kthSmallest(self, root: Optional[TreeNode], k: int) -> int:
                    stack, node = [], root
                    while stack or node:
                        while node:
                            stack.append(node)
                            node = node.left
                        node = stack.pop()
                        k -= 1
                        if k == 0:
                            return node.val
                        node = node.right
            """#,
            time: "O(h + k)", space: "O(h)"),

        Problem(
            id: "binary-tree-right-side-view", number: 199, title: "Binary Tree Right Side View", difficulty: .medium, topic: .trees,
            description: "Imagine standing on the **right side** of a binary tree. Return the values of the nodes you can see, ordered from top to bottom.",
            examples: [ex("root = [1,2,3,null,5,null,4]", "[1,3,4]"), ex("root = [1,2,3,4]", "[1,3,4]")],
            constraints: ["0 ≤ number of nodes ≤ 100", "-100 ≤ Node.val ≤ 100"],
            hints: ["You see exactly one node per level.", "Which node of each level is visible from the right?"],
            approach: ["Run a **level-order BFS**.", "Before processing a level, the **last** node in the queue is that level's rightmost node, so record it.", "Then pop the whole level and enqueue its children left to right."],
            solution: treeNodeHeader + #"""
            class Solution:
                def rightSideView(self, root: Optional[TreeNode]) -> List[int]:
                    result = []
                    queue = deque([root] if root else [])
                    while queue:
                        result.append(queue[-1].val)  # rightmost node of this level
                        for _ in range(len(queue)):
                            node = queue.popleft()
                            if node.left:
                                queue.append(node.left)
                            if node.right:
                                queue.append(node.right)
                    return result
            """#,
            time: "O(n)", space: "O(n)"),
    ]

    // MARK: Heap, backtracking, graphs

    private static let extraSearchGraphs: [Problem] = [
        Problem(
            id: "kth-largest-element-in-an-array", number: 215, title: "Kth Largest Element in an Array", difficulty: .medium, topic: .heap,
            description: "Given an integer array `nums` and an integer `k`, return the `k`th largest element (in sorted order, not the kth distinct one).",
            examples: [ex("nums = [3,2,1,5,6,4], k = 2", "5"), ex("nums = [3,2,3,1,2,4,5,5,6], k = 4", "4")],
            constraints: ["1 ≤ k ≤ nums.length ≤ 10⁵", "-10⁴ ≤ nums[i] ≤ 10⁴"],
            hints: ["Sorting works in O(n log n). Can you avoid sorting everything?", "Keep only the k largest values seen so far. Which one would you throw out next?"],
            approach: ["Keep a **min-heap** of size k holding the k largest values seen so far.", "Push each number; if the heap grows past k, pop its smallest.", "The heap's top (its smallest) is the kth largest overall."],
            solution: #"""
            class Solution:
                def findKthLargest(self, nums: List[int], k: int) -> int:
                    heap = []
                    for n in nums:
                        heapq.heappush(heap, n)
                        if len(heap) > k:
                            heapq.heappop(heap)  # drop the smallest
                    return heap[0]
            """#,
            time: "O(n log k)", space: "O(k)"),

        Problem(
            id: "task-scheduler", number: 621, title: "Task Scheduler", difficulty: .medium, topic: .heap,
            description: "A CPU runs tasks labeled with letters, one per time unit. Two runs of the **same** task must be separated by at least `n` units (the CPU may idle).\n\nReturn the minimum number of units needed to finish every task.",
            examples: [ex(#"tasks = ["A","A","A","B","B","B"], n = 2"#, "8", "A → B → idle → A → B → idle → A → B"), ex(#"tasks = ["A","C","A","B","D","B"], n = 1"#, "6")],
            constraints: ["1 ≤ tasks.length ≤ 10⁴", "Tasks are uppercase letters", "0 ≤ n ≤ 100"],
            hints: ["The most frequent task decides the shape of the schedule.", "Lay the most frequent task out with gaps of n, then fill the gaps with everything else."],
            approach: ["Let `top` be the highest task count and `ties` how many tasks share it.", "The frequent task forms `top - 1` frames of length `n + 1`, plus a final row of the `ties` tasks.", "If there are more tasks than slots, there's no idling at all, so the answer is `max(len(tasks), frames)`."],
            solution: #"""
            class Solution:
                def leastInterval(self, tasks: List[str], n: int) -> int:
                    counts = Counter(tasks).values()
                    top = max(counts)
                    ties = sum(1 for c in counts if c == top)
                    # (top - 1) frames of length n + 1, then one last row
                    return max(len(tasks), (top - 1) * (n + 1) + ties)
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "word-search", number: 79, title: "Word Search", difficulty: .medium, topic: .backtracking,
            description: "Given an `m × n` grid of letters and a string `word`, return `true` if the word can be built from **adjacent** cells (horizontally or vertically). A cell may be used at most once.",
            examples: [ex(#"board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED""#, "true"), ex(#"same board, word = "ABCB""#, "false")],
            constraints: ["1 ≤ m, n ≤ 6", "1 ≤ word.length ≤ 15"],
            hints: ["Try starting the word from every cell.", "Mark a cell as used while you explore from it, and unmark it when you backtrack."],
            approach: ["From every cell, run a **DFS** that matches `word[i]` and then explores the four neighbors for `word[i + 1]`.", "Temporarily overwrite the cell with `#` so the path can't reuse it.", "**Restore** the letter on the way back (backtracking)."],
            solution: #"""
            class Solution:
                def exist(self, board: List[List[str]], word: str) -> bool:
                    rows, cols = len(board), len(board[0])

                    def dfs(r, c, i):
                        if i == len(word):
                            return True
                        if not (0 <= r < rows and 0 <= c < cols) or board[r][c] != word[i]:
                            return False
                        board[r][c] = "#"  # mark visited
                        found = (dfs(r + 1, c, i + 1) or dfs(r - 1, c, i + 1) or
                                 dfs(r, c + 1, i + 1) or dfs(r, c - 1, i + 1))
                        board[r][c] = word[i]  # undo
                        return found

                    return any(dfs(r, c, 0) for r in range(rows) for c in range(cols))
            """#,
            time: "O(m · n · 4ᴸ)", space: "O(L)"),

        Problem(
            id: "letter-combinations-of-a-phone-number", number: 17, title: "Letter Combinations of a Phone Number", difficulty: .medium, topic: .backtracking,
            description: "Given a string of digits `2-9`, return every letter combination the number could represent on a phone keypad (2 → abc, 3 → def, …, 9 → wxyz).",
            examples: [ex(#"digits = "23""#, #"["ad","ae","af","bd","be","bf","cd","ce","cf"]"#), ex(#"digits = """#, "[]")],
            constraints: ["0 ≤ digits.length ≤ 4", "digits[i] is in the range ['2', '9']"],
            hints: ["Pick one letter for the first digit, then solve the rest of the digits.", "The recursion depth equals the number of digits."],
            approach: ["Map each digit to its letters.", "**Backtrack**: at depth `i`, try each letter of `digits[i]` and recurse to depth `i + 1`.", "When the path is as long as `digits`, record it."],
            solution: #"""
            class Solution:
                def letterCombinations(self, digits: str) -> List[str]:
                    if not digits:
                        return []
                    letters = {"2": "abc", "3": "def", "4": "ghi", "5": "jkl",
                               "6": "mno", "7": "pqrs", "8": "tuv", "9": "wxyz"}
                    result = []

                    def backtrack(i, path):
                        if i == len(digits):
                            result.append(path)
                            return
                        for ch in letters[digits[i]]:
                            backtrack(i + 1, path + ch)

                    backtrack(0, "")
                    return result
            """#,
            time: "O(n · 4ⁿ)", space: "O(n)"),

        Problem(
            id: "n-queens", number: 51, title: "N-Queens", difficulty: .hard, topic: .backtracking,
            description: "Place `n` queens on an `n × n` chessboard so that no two queens attack each other (same row, column or diagonal).\n\nReturn every distinct solution, with `\"Q\"` for a queen and `\".\"` for an empty square.",
            examples: [ex("n = 4", #"[[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]"#), ex("n = 1", #"[["Q"]]"#)],
            constraints: ["1 ≤ n ≤ 9"],
            hints: ["Each row holds exactly one queen, so place them row by row.", "Cells on the same diagonal share `r - c`; cells on the same anti-diagonal share `r + c`."],
            approach: ["Place one queen per row, recursing to the next row.", "Track used **columns**, **diagonals** (`r - c`) and **anti-diagonals** (`r + c`) in sets for O(1) conflict checks.", "Undo each placement after exploring it."],
            solution: #"""
            class Solution:
                def solveNQueens(self, n: int) -> List[List[str]]:
                    cols, diag, anti = set(), set(), set()
                    board = [["."] * n for _ in range(n)]
                    result = []

                    def place(r):
                        if r == n:
                            result.append(["".join(row) for row in board])
                            return
                        for c in range(n):
                            if c in cols or r - c in diag or r + c in anti:
                                continue
                            cols.add(c)
                            diag.add(r - c)
                            anti.add(r + c)
                            board[r][c] = "Q"
                            place(r + 1)
                            cols.remove(c)
                            diag.remove(r - c)
                            anti.remove(r + c)
                            board[r][c] = "."

                    place(0)
                    return result
            """#,
            time: "O(n!)", space: "O(n²)"),

        Problem(
            id: "max-area-of-island", number: 695, title: "Max Area of Island", difficulty: .medium, topic: .graphs,
            description: "Given an `m × n` binary grid where `1` is land and `0` is water, return the area of the **largest island** (4-directionally connected land). Return 0 if there is no island.",
            examples: [ex("grid = 8 × 13 grid with several islands", "6"), ex("grid = [[0,0,0,0,0,0,0,0]]", "0")],
            constraints: ["1 ≤ m, n ≤ 50", "grid[i][j] is 0 or 1"],
            hints: ["This is Number of Islands, but count cells instead of islands.", "A DFS can return the size of the island it explored."],
            approach: ["DFS from each land cell, returning `1 +` the area of its four neighbors.", "**Sink** each visited cell (set it to 0) so it's counted once.", "Track the maximum over all starting cells."],
            solution: #"""
            class Solution:
                def maxAreaOfIsland(self, grid: List[List[int]]) -> int:
                    rows, cols = len(grid), len(grid[0])

                    def dfs(r, c):
                        if not (0 <= r < rows and 0 <= c < cols) or grid[r][c] != 1:
                            return 0
                        grid[r][c] = 0  # sink it so it's counted once
                        return 1 + dfs(r + 1, c) + dfs(r - 1, c) + dfs(r, c + 1) + dfs(r, c - 1)

                    return max(dfs(r, c) for r in range(rows) for c in range(cols))
            """#,
            time: "O(m · n)", space: "O(m · n)"),

        Problem(
            id: "pacific-atlantic-water-flow", number: 417, title: "Pacific Atlantic Water Flow", difficulty: .medium, topic: .graphs,
            description: "An island is an `m × n` grid of heights. The **Pacific** touches the top and left edges, the **Atlantic** the bottom and right edges. Rain flows to a neighbor with height ≤ the current cell.\n\nReturn every cell from which water can reach **both** oceans.",
            examples: [ex("heights = [[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]", "[[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]]"), ex("heights = [[1]]", "[[0,0]]")],
            constraints: ["1 ≤ m, n ≤ 200", "0 ≤ heights[r][c] ≤ 10⁵"],
            hints: ["Checking every cell separately repeats a lot of work.", "Reverse the flow: start from each ocean's edge and climb **uphill**."],
            approach: ["Run a DFS from every Pacific-edge cell, moving only to neighbors that are **at least as high**. These cells can drain to the Pacific.", "Do the same from the Atlantic edges.", "The answer is the **intersection** of the two reachable sets."],
            solution: #"""
            class Solution:
                def pacificAtlantic(self, heights: List[List[int]]) -> List[List[int]]:
                    rows, cols = len(heights), len(heights[0])
                    pacific, atlantic = set(), set()

                    def dfs(r, c, seen, prev):
                        if (r, c) in seen or not (0 <= r < rows and 0 <= c < cols) or heights[r][c] < prev:
                            return
                        seen.add((r, c))
                        for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                            dfs(r + dr, c + dc, seen, heights[r][c])

                    for c in range(cols):
                        dfs(0, c, pacific, 0)
                        dfs(rows - 1, c, atlantic, 0)
                    for r in range(rows):
                        dfs(r, 0, pacific, 0)
                        dfs(r, cols - 1, atlantic, 0)
                    return [list(cell) for cell in pacific & atlantic]
            """#,
            time: "O(m · n)", space: "O(m · n)"),

        Problem(
            id: "course-schedule-ii", number: 210, title: "Course Schedule II", difficulty: .medium, topic: .graphs,
            description: "There are `numCourses` courses. `prerequisites[i] = [a, b]` means you must take `b` before `a`.\n\nReturn **an order** in which you can finish every course, or an empty array if that's impossible.",
            examples: [ex("numCourses = 2, prerequisites = [[1,0]]", "[0,1]"), ex("numCourses = 4, prerequisites = [[1,0],[2,0],[3,1],[3,2]]", "[0,1,2,3] or [0,2,1,3]")],
            constraints: ["1 ≤ numCourses ≤ 2000", "0 ≤ prerequisites.length ≤ numCourses · (numCourses - 1)"],
            hints: ["Start with courses that have no prerequisites.", "Taking a course may free up others. Count how many prerequisites each course still waits on."],
            approach: ["Build the graph `pre → course` and count each course's **in-degree**.", "**Kahn's algorithm**: queue every course with in-degree 0, pop one, add it to the order, and decrement its neighbors.", "If the order includes every course, return it; otherwise there's a cycle."],
            solution: #"""
            class Solution:
                def findOrder(self, numCourses: int, prerequisites: List[List[int]]) -> List[int]:
                    graph = defaultdict(list)
                    indegree = [0] * numCourses
                    for course, pre in prerequisites:
                        graph[pre].append(course)
                        indegree[course] += 1

                    queue = deque(c for c in range(numCourses) if indegree[c] == 0)
                    order = []
                    while queue:
                        node = queue.popleft()
                        order.append(node)
                        for nxt in graph[node]:
                            indegree[nxt] -= 1
                            if indegree[nxt] == 0:
                                queue.append(nxt)
                    return order if len(order) == numCourses else []
            """#,
            time: "O(V + E)", space: "O(V + E)"),

        Problem(
            id: "cheapest-flights-within-k-stops", number: 787, title: "Cheapest Flights Within K Stops", difficulty: .medium, topic: .advancedGraphs,
            description: "There are `n` cities and `flights[i] = [from, to, price]`. Return the cheapest price from `src` to `dst` using **at most `k` stops**, or `-1` if there's no such route.",
            examples: [ex("n = 4, flights = [[0,1,100],[1,2,100],[2,0,100],[1,3,600],[2,3,200]], src = 0, dst = 3, k = 1", "700", "0 → 1 → 3 costs 700. The cheaper 0 → 1 → 2 → 3 uses 2 stops."), ex("n = 3, flights = [[0,1,100],[1,2,100],[0,2,500]], src = 0, dst = 2, k = 1", "200")],
            constraints: ["1 ≤ n ≤ 100", "0 ≤ k < n", "1 ≤ price ≤ 10⁴"],
            hints: ["Plain Dijkstra ignores the stop limit.", "Bellman-Ford's i-th round finds the cheapest routes that use at most i edges."],
            approach: ["Run **Bellman-Ford** for exactly `k + 1` rounds (k stops = k + 1 flights).", "Each round relaxes every flight using the prices from the **previous** round (copy into `temp`), so a route never gains more than one flight per round.", "Return the price at `dst`, or -1 if unreachable."],
            solution: #"""
            class Solution:
                def findCheapestPrice(self, n: int, flights: List[List[int]], src: int, dst: int, k: int) -> int:
                    prices = [float("inf")] * n
                    prices[src] = 0
                    for _ in range(k + 1):  # k stops = k + 1 flights
                        temp = prices[:]
                        for u, v, cost in flights:
                            if prices[u] + cost < temp[v]:
                                temp[v] = prices[u] + cost
                        prices = temp
                    return -1 if prices[dst] == float("inf") else prices[dst]
            """#,
            time: "O(k · E)", space: "O(n)"),
    ]

    // MARK: Dynamic programming

    private static let extraDP: [Problem] = [
        Problem(
            id: "min-cost-climbing-stairs", number: 746, title: "Min Cost Climbing Stairs", difficulty: .easy, topic: .dp1d,
            description: "`cost[i]` is the price of stepping on stair `i`. After paying, you can climb **one or two** stairs. You may start on stair 0 or stair 1.\n\nReturn the minimum cost to reach the top (just past the last stair).",
            examples: [ex("cost = [10,15,20]", "15", "Start on stair 1, pay 15, climb two steps."), ex("cost = [1,100,1,1,1,100,1,1,100,1]", "6")],
            constraints: ["2 ≤ cost.length ≤ 1000", "0 ≤ cost[i] ≤ 999"],
            hints: ["To stand on step i, you came from i-1 (paying cost[i-1]) or i-2 (paying cost[i-2]).", "Only the last two answers matter."],
            approach: ["Let `dp[i]` be the cheapest way to **stand on** step i. `dp[0] = dp[1] = 0`.", "`dp[i] = min(dp[i-1] + cost[i-1], dp[i-2] + cost[i-2])`.", "Roll two variables forward and return `dp[n]`."],
            solution: #"""
            class Solution:
                def minCostClimbingStairs(self, cost: List[int]) -> int:
                    a, b = 0, 0  # cheapest way to stand on step i-2 and i-1
                    for i in range(2, len(cost) + 1):
                        a, b = b, min(b + cost[i - 1], a + cost[i - 2])
                    return b
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "house-robber-ii", number: 213, title: "House Robber II", difficulty: .medium, topic: .dp1d,
            description: "Same as House Robber, but the houses are arranged in a **circle**: the first and last houses are neighbors.\n\nReturn the maximum amount you can rob without robbing two adjacent houses.",
            examples: [ex("nums = [2,3,2]", "3", "Houses 0 and 2 are adjacent, so rob house 1."), ex("nums = [1,2,3,1]", "4")],
            constraints: ["1 ≤ nums.length ≤ 100", "0 ≤ nums[i] ≤ 1000"],
            hints: ["You can never rob both the first and the last house.", "So solve the straight-line problem twice: without the first house, and without the last."],
            approach: ["The circle only adds one rule: first and last can't both be robbed.", "Run regular House Robber on `nums[1:]` and on `nums[:-1]`.", "Return the larger result (handle a single house separately)."],
            solution: #"""
            class Solution:
                def rob(self, nums: List[int]) -> int:
                    def rob_line(houses):
                        prev, curr = 0, 0
                        for n in houses:
                            prev, curr = curr, max(curr, prev + n)
                        return curr

                    if len(nums) == 1:
                        return nums[0]
                    # first and last are neighbors: leave out one or the other
                    return max(rob_line(nums[1:]), rob_line(nums[:-1]))
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "decode-ways", number: 91, title: "Decode Ways", difficulty: .medium, topic: .dp1d,
            description: "Letters are encoded as numbers: `A → 1`, `B → 2`, …, `Z → 26`. Given a string of digits `s`, return the number of ways to **decode** it.",
            examples: [ex(#"s = "12""#, "2", #""AB" (1 2) or "L" (12)."#), ex(#"s = "226""#, "3"), ex(#"s = "06""#, "0", #""06" isn't valid, and "0" maps to nothing."#)],
            constraints: ["1 ≤ s.length ≤ 100", "s contains digits only"],
            hints: ["The last character is decoded alone (if it isn't '0') or together with the previous one (if they form 10–26).", "ways(i) = ways(i-1) [single] + ways(i-2) [pair]."],
            approach: ["Let `one` be the number of ways to decode the prefix ending at the previous character, and `two` the one before.", "A non-zero digit can stand alone: add `one`. A valid pair `10..26` adds `two`.", "Roll the two values forward; the last `one` is the answer."],
            solution: #"""
            class Solution:
                def numDecodings(self, s: str) -> int:
                    # one = ways to decode s[:i], two = ways to decode s[:i-1]
                    one, two = 1, 0
                    for i, ch in enumerate(s):
                        current = one if ch != "0" else 0
                        if i > 0 and 10 <= int(s[i - 1:i + 1]) <= 26:
                            current += two
                        one, two = current, one
                    return one
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "word-break", number: 139, title: "Word Break", difficulty: .medium, topic: .dp1d,
            description: "Given a string `s` and a dictionary `wordDict`, return `true` if `s` can be split into a sequence of one or more dictionary words. Words may be reused.",
            examples: [ex(#"s = "leetcode", wordDict = ["leet","code"]"#, "true"), ex(#"s = "applepenapple", wordDict = ["apple","pen"]"#, "true"), ex(#"s = "catsandog", wordDict = ["cats","dog","sand","and","cat"]"#, "false")],
            constraints: ["1 ≤ s.length ≤ 300", "1 ≤ wordDict.length ≤ 1000"],
            hints: ["If `s[:j]` can be split and `s[j:i]` is a word, then `s[:i]` can be split.", "Build up the answer for every prefix length."],
            approach: ["`dp[i]` is True when the prefix `s[:i]` can be segmented. `dp[0]` (empty) is True.", "For each `i`, look for a split point `j` with `dp[j]` True and `s[j:i]` in the dictionary.", "The answer is `dp[len(s)]`."],
            solution: #"""
            class Solution:
                def wordBreak(self, s: str, wordDict: List[str]) -> bool:
                    words = set(wordDict)
                    dp = [False] * (len(s) + 1)  # dp[i]: s[:i] can be segmented
                    dp[0] = True
                    for i in range(1, len(s) + 1):
                        for j in range(i):
                            if dp[j] and s[j:i] in words:
                                dp[i] = True
                                break
                    return dp[len(s)]
            """#,
            time: "O(n³)", space: "O(n)"),

        Problem(
            id: "longest-palindromic-substring", number: 5, title: "Longest Palindromic Substring", difficulty: .medium, topic: .dp1d,
            description: "Given a string `s`, return the **longest palindromic substring** in `s`.",
            examples: [ex(#"s = "babad""#, #""bab""#, #""aba" is also valid."#), ex(#"s = "cbbd""#, #""bb""#)],
            constraints: ["1 ≤ s.length ≤ 1000", "Digits and English letters"],
            hints: ["Every palindrome mirrors around a center.", "There are 2n - 1 centers: each character (odd length) and each gap between characters (even length)."],
            approach: ["For each center, **expand outward** while the characters on both sides match.", "Try both an odd center `(i, i)` and an even center `(i, i + 1)`.", "Keep the longest palindrome found."],
            solution: #"""
            class Solution:
                def longestPalindrome(self, s: str) -> str:
                    best = ""

                    def expand(l, r):
                        while l >= 0 and r < len(s) and s[l] == s[r]:
                            l, r = l - 1, r + 1
                        return s[l + 1:r]

                    for i in range(len(s)):
                        for candidate in (expand(i, i), expand(i, i + 1)):  # odd, even
                            if len(candidate) > len(best):
                                best = candidate
                    return best
            """#,
            time: "O(n²)", space: "O(1)"),

        Problem(
            id: "edit-distance", number: 72, title: "Edit Distance", difficulty: .medium, topic: .dp2d,
            description: "Given two strings `word1` and `word2`, return the minimum number of operations to turn `word1` into `word2`. Allowed operations: **insert**, **delete** or **replace** a character.",
            examples: [ex(#"word1 = "horse", word2 = "ros""#, "3", "horse → rorse (replace) → rose (delete) → ros (delete)"), ex(#"word1 = "intention", word2 = "execution""#, "5")],
            constraints: ["0 ≤ word1.length, word2.length ≤ 500", "Lowercase English letters"],
            hints: ["Compare the first characters. If they match, no operation is needed for them.", "Otherwise try all three operations and see which leaves the cheapest subproblem."],
            approach: ["`dp[i][j]` = edits to turn the suffix `word1[i:]` into `word2[j:]`. Turning a suffix into an empty string costs its length.", "If `word1[i] == word2[j]`, take `dp[i+1][j+1]`.", "Otherwise `1 + min(delete dp[i+1][j], insert dp[i][j+1], replace dp[i+1][j+1])`."],
            solution: #"""
            class Solution:
                def minDistance(self, word1: str, word2: str) -> int:
                    m, n = len(word1), len(word2)
                    # dp[i][j] = edits to turn word1[i:] into word2[j:]
                    dp = [[0] * (n + 1) for _ in range(m + 1)]
                    for i in range(m + 1):
                        dp[i][n] = m - i
                    for j in range(n + 1):
                        dp[m][j] = n - j
                    for i in range(m - 1, -1, -1):
                        for j in range(n - 1, -1, -1):
                            if word1[i] == word2[j]:
                                dp[i][j] = dp[i + 1][j + 1]
                            else:
                                dp[i][j] = 1 + min(dp[i + 1][j],      # delete
                                                   dp[i][j + 1],      # insert
                                                   dp[i + 1][j + 1])  # replace
                    return dp[0][0]
            """#,
            time: "O(m · n)", space: "O(m · n)"),

        Problem(
            id: "coin-change-ii", number: 518, title: "Coin Change II", difficulty: .medium, topic: .dp2d,
            description: "Given coin denominations `coins` (unlimited supply) and an `amount`, return the number of **combinations** that make up that amount. Order doesn't matter: 1+2 and 2+1 are the same.",
            examples: [ex("amount = 5, coins = [1,2,5]", "4", "5, 2+2+1, 2+1+1+1, 1+1+1+1+1"), ex("amount = 3, coins = [2]", "0")],
            constraints: ["1 ≤ coins.length ≤ 300", "0 ≤ amount ≤ 5000", "All coins are unique"],
            hints: ["Counting combinations, not orderings: decide how many of each coin to use, one coin type at a time.", "Put the coin loop on the outside."],
            approach: ["`dp[a]` = number of ways to make `a` with the coins processed so far. `dp[0] = 1`.", "For each coin (**outer loop**), for every amount from `coin` up: `dp[a] += dp[a - coin]`.", "Looping coins on the outside counts each combination once, in a fixed coin order."],
            solution: #"""
            class Solution:
                def change(self, amount: int, coins: List[int]) -> int:
                    dp = [1] + [0] * amount  # dp[a] = ways to make a
                    for coin in coins:  # coins outside -> combinations, not orderings
                        for a in range(coin, amount + 1):
                            dp[a] += dp[a - coin]
                    return dp[amount]
            """#,
            time: "O(amount · coins)", space: "O(amount)"),
    ]

    // MARK: Greedy, intervals, math, bits

    private static let extraMisc: [Problem] = [
        Problem(
            id: "gas-station", number: 134, title: "Gas Station", difficulty: .medium, topic: .greedy,
            description: "There are `n` gas stations on a circular route. Station `i` has `gas[i]` fuel, and driving to the next station costs `cost[i]`. You start with an empty tank.\n\nReturn the starting station that lets you complete the circuit once, or `-1`. The answer is unique if it exists.",
            examples: [ex("gas = [1,2,3,4,5], cost = [3,4,5,1,2]", "3"), ex("gas = [2,3,4], cost = [3,4,3]", "-1")],
            constraints: ["1 ≤ n ≤ 10⁵", "0 ≤ gas[i], cost[i] ≤ 10⁴"],
            hints: ["If total gas < total cost, it's impossible. Otherwise a start always exists.", "If you run dry before station i + 1, no station between your start and i can be the answer."],
            approach: ["If `sum(gas) < sum(cost)`, return -1.", "Drive from `start`, keeping a running `tank`.", "Whenever the tank goes negative at station i, **restart** from `i + 1` with an empty tank. The last start is the answer."],
            solution: #"""
            class Solution:
                def canCompleteCircuit(self, gas: List[int], cost: List[int]) -> int:
                    if sum(gas) < sum(cost):
                        return -1
                    tank, start = 0, 0
                    for i in range(len(gas)):
                        tank += gas[i] - cost[i]
                        if tank < 0:  # can't reach i + 1 from start
                            tank, start = 0, i + 1
                    return start
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "jump-game-ii", number: 45, title: "Jump Game II", difficulty: .medium, topic: .greedy,
            description: "You start at index 0. `nums[i]` is the maximum jump length from index `i`.\n\nReturn the **minimum number of jumps** to reach the last index. The last index is always reachable.",
            examples: [ex("nums = [2,3,1,1,4]", "2", "Jump 1 step to index 1, then 3 steps to the end."), ex("nums = [2,3,0,1,4]", "2")],
            constraints: ["1 ≤ nums.length ≤ 10⁴", "0 ≤ nums[i] ≤ 1000"],
            hints: ["Think in levels, like BFS: all indices reachable with exactly k jumps form a window.", "The next window ends at the farthest index any cell in the current window can reach."],
            approach: ["Keep a window `[l, r]` of indices reachable with `jumps` jumps.", "The next window is `[r + 1, farthest]`, where `farthest` is the max of `i + nums[i]` over the current window.", "Count windows until `r` reaches the last index."],
            solution: #"""
            class Solution:
                def jump(self, nums: List[int]) -> int:
                    jumps = 0
                    l = r = 0  # window of indices reachable with `jumps` jumps
                    while r < len(nums) - 1:
                        farthest = max(i + nums[i] for i in range(l, r + 1))
                        l, r = r + 1, farthest
                        jumps += 1
                    return jumps
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "insert-interval", number: 57, title: "Insert Interval", difficulty: .medium, topic: .intervals,
            description: "`intervals` is a list of non-overlapping intervals sorted by start. Insert `newInterval`, merging overlaps where necessary, and return the result (still sorted and non-overlapping).",
            examples: [ex("intervals = [[1,3],[6,9]], newInterval = [2,5]", "[[1,5],[6,9]]"), ex("intervals = [[1,2],[3,5],[6,7],[8,10],[12,16]], newInterval = [4,8]", "[[1,2],[3,10],[12,16]]")],
            constraints: ["0 ≤ intervals.length ≤ 10⁴", "intervals is sorted by start", "intervals don't overlap"],
            hints: ["Each existing interval is either fully before, fully after, or overlapping the new one.", "Overlapping intervals get absorbed into the new interval."],
            approach: ["Intervals that end **before** the new one starts are copied as they are.", "If the new interval ends before the current one starts, insert it and append the rest.", "Otherwise they **overlap**: widen the new interval to cover both."],
            solution: #"""
            class Solution:
                def insert(self, intervals: List[List[int]], newInterval: List[int]) -> List[List[int]]:
                    result = []
                    for i, (start, end) in enumerate(intervals):
                        if newInterval[1] < start:  # new one ends before this one
                            result.append(newInterval)
                            return result + intervals[i:]
                        if newInterval[0] > end:  # new one starts after this one
                            result.append([start, end])
                        else:  # overlap: merge into newInterval
                            newInterval = [min(newInterval[0], start), max(newInterval[1], end)]
                    result.append(newInterval)
                    return result
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "spiral-matrix", number: 54, title: "Spiral Matrix", difficulty: .medium, topic: .math,
            description: "Given an `m × n` matrix, return all of its elements in **spiral order** (clockwise, starting from the top-left).",
            examples: [ex("matrix = [[1,2,3],[4,5,6],[7,8,9]]", "[1,2,3,6,9,8,7,4,5]"), ex("matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]", "[1,2,3,4,8,12,11,10,9,5,6,7]")],
            constraints: ["1 ≤ m, n ≤ 10", "-100 ≤ matrix[i][j] ≤ 100"],
            hints: ["Keep four boundaries: top, bottom, left, right.", "After walking each side, pull that boundary inward. Watch out for a single remaining row or column."],
            approach: ["Maintain the boundaries `top`, `bottom`, `left`, `right`.", "Walk the top row, the right column, the bottom row (reversed) and the left column (reversed), shrinking a boundary after each.", "Stop as soon as the boundaries cross, which also avoids double-counting a lone row or column."],
            solution: #"""
            class Solution:
                def spiralOrder(self, matrix: List[List[int]]) -> List[int]:
                    result = []
                    top, bottom = 0, len(matrix)
                    left, right = 0, len(matrix[0])
                    while top < bottom and left < right:
                        for c in range(left, right):
                            result.append(matrix[top][c])
                        top += 1
                        for r in range(top, bottom):
                            result.append(matrix[r][right - 1])
                        right -= 1
                        if not (top < bottom and left < right):
                            break
                        for c in range(right - 1, left - 1, -1):
                            result.append(matrix[bottom - 1][c])
                        bottom -= 1
                        for r in range(bottom - 1, top - 1, -1):
                            result.append(matrix[r][left])
                        left += 1
                    return result
            """#,
            time: "O(m · n)", space: "O(1)"),

        Problem(
            id: "set-matrix-zeroes", number: 73, title: "Set Matrix Zeroes", difficulty: .medium, topic: .math,
            description: "Given an `m × n` integer matrix, if an element is `0`, set its **entire row and column** to `0`. Do it in place.",
            examples: [ex("matrix = [[1,1,1],[1,0,1],[1,1,1]]", "[[1,0,1],[0,0,0],[1,0,1]]"), ex("matrix = [[0,1,2,0],[3,4,5,2],[1,3,1,5]]", "[[0,0,0,0],[0,4,5,0],[0,3,1,0]]")],
            constraints: ["1 ≤ m, n ≤ 200", "-2³¹ ≤ matrix[i][j] ≤ 2³¹ - 1"],
            hints: ["Zeroing as you scan would wipe out information you still need.", "First record which rows and columns contain a zero, then zero them in a second pass."],
            approach: ["**Pass 1**: record every row and column that contains a 0.", "**Pass 2**: zero every cell whose row or column was recorded.", "Follow-up: use the first row and column themselves as the markers for O(1) extra space."],
            solution: #"""
            class Solution:
                def setZeroes(self, matrix: List[List[int]]) -> None:
                    rows, cols = len(matrix), len(matrix[0])
                    zero_rows, zero_cols = set(), set()
                    for r in range(rows):
                        for c in range(cols):
                            if matrix[r][c] == 0:
                                zero_rows.add(r)
                                zero_cols.add(c)
                    for r in range(rows):
                        for c in range(cols):
                            if r in zero_rows or c in zero_cols:
                                matrix[r][c] = 0
            """#,
            time: "O(m · n)", space: "O(m + n)"),

        Problem(
            id: "powx-n", number: 50, title: "Pow(x, n)", difficulty: .medium, topic: .math,
            description: "Implement `pow(x, n)`, which calculates `x` raised to the power `n`. `n` may be negative.",
            examples: [ex("x = 2.00000, n = 10", "1024.00000"), ex("x = 2.00000, n = -2", "0.25000", "2⁻² = 1/4")],
            constraints: ["-100.0 < x < 100.0", "-2³¹ ≤ n ≤ 2³¹ - 1"],
            hints: ["Multiplying x by itself n times is too slow for n up to 2³¹.", "x¹⁰ = (x²)⁵. Square the base and halve the exponent."],
            approach: ["For a negative `n`, use `1 / x` and `-n`.", "**Fast exponentiation**: look at the bits of `n`. Whenever the lowest bit is 1, multiply the result by the current `x`.", "Square `x` and shift `n` right each round. That's O(log n) rounds."],
            solution: #"""
            class Solution:
                def myPow(self, x: float, n: int) -> float:
                    if n < 0:
                        x, n = 1 / x, -n
                    result = 1.0
                    while n:
                        if n & 1:  # this bit contributes the current x
                            result *= x
                        x *= x
                        n >>= 1
                    return result
            """#,
            time: "O(log n)", space: "O(1)"),

        Problem(
            id: "number-of-1-bits", number: 191, title: "Number of 1 Bits", difficulty: .easy, topic: .bitManipulation,
            description: "Given a positive integer `n`, return the number of `1` bits in its binary representation (its **Hamming weight**).",
            examples: [ex("n = 11", "3", "11 is 1011 in binary."), ex("n = 128", "1")],
            constraints: ["1 ≤ n ≤ 2³¹ - 1"],
            hints: ["You could check the lowest bit and shift, 32 times.", "`n & (n - 1)` removes the lowest set bit. How many times can you do that?"],
            approach: ["`n - 1` flips the lowest set bit and every 0 below it.", "So `n &= n - 1` **clears exactly one** set bit.", "Count how many times you can do it before `n` is 0."],
            solution: #"""
            class Solution:
                def hammingWeight(self, n: int) -> int:
                    count = 0
                    while n:
                        n &= n - 1  # clear the lowest set bit
                        count += 1
                    return count
            """#,
            time: "O(1)", space: "O(1)"),

        Problem(
            id: "missing-number", number: 268, title: "Missing Number", difficulty: .easy, topic: .bitManipulation,
            description: "Given an array `nums` containing `n` distinct numbers from the range `[0, n]`, return the **only number in the range that is missing**.",
            examples: [ex("nums = [3,0,1]", "2"), ex("nums = [9,6,4,2,3,5,7,0,1]", "8")],
            constraints: ["1 ≤ n ≤ 10⁴", "All numbers are unique and in [0, n]"],
            hints: ["`a ^ a = 0` and `a ^ 0 = a`.", "XOR every index and every value together. Everything appears twice except the missing number."],
            approach: ["XOR together all indices `0..n` and all values.", "Each present number appears twice (as an index and as a value), so the pairs **cancel**.", "Only the missing number is left. (Summing `0..n` minus `sum(nums)` also works.)"],
            solution: #"""
            class Solution:
                def missingNumber(self, nums: List[int]) -> int:
                    result = len(nums)
                    for i, n in enumerate(nums):
                        result ^= i ^ n  # pairs cancel, the missing one remains
                    return result
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "reverse-bits", number: 190, title: "Reverse Bits", difficulty: .easy, topic: .bitManipulation,
            description: "Reverse the bits of a 32-bit unsigned integer `n` and return the result.",
            examples: [ex("n = 43261596 (00000010100101000001111010011100)", "964176192 (00111001011110000010100101000000)")],
            constraints: ["The input is a 32-bit unsigned integer"],
            hints: ["Read bits off the right end of n with `n & 1`.", "Push each bit onto the right end of the result by shifting the result left first."],
            approach: ["Repeat 32 times:", "Shift `result` left by one and add the lowest bit of `n`.", "Shift `n` right by one."],
            solution: #"""
            class Solution:
                def reverseBits(self, n: int) -> int:
                    result = 0
                    for _ in range(32):
                        result = (result << 1) | (n & 1)
                        n >>= 1
                    return result
            """#,
            time: "O(1)", space: "O(1)"),
    ]

    static let extraInsights: [String: String] = [
        "valid-anagram": "Count up for one string and down for the other; anagrams cancel to all zeros.",
        "product-of-array-except-self": "Answer = product of everything left × product of everything right: two passes, no division.",
        "valid-sudoku": "One set per row, column and box. Box id = `(r // 3, c // 3)`.",
        "two-sum-ii-input-array-is-sorted": "Sorted input means the sum tells you which pointer to move.",
        "permutation-in-string": "A fixed-size window whose letter counts must equal those of `s1`.",
        "evaluate-reverse-polish-notation": "Operands wait on a stack; each operator pops two and pushes one.",
        "generate-parentheses": "Add `(` while open < n, and `)` only while close < open.",
        "car-fleet": "Sort by position from the target. A car that would arrive no later than the fleet ahead joins it.",
        "largest-rectangle-in-histogram": "An increasing stack. A shorter bar ends every taller bar's rectangle, so score them as they pop.",
        "search-a-2d-matrix": "The matrix is one sorted list in disguise: index k is `matrix[k // n][k % n]`.",
        "find-minimum-in-rotated-sorted-array": "Compare mid with the right end: bigger means the drop is to the right.",
        "time-based-key-value-store": "Timestamps arrive sorted, so binary search for the last one ≤ the query.",
        "remove-nth-node-from-end-of-list": "Two pointers n apart: when the front one finishes, the back one is in position.",
        "reorder-list": "Find the middle, reverse the second half, then zip the two halves together.",
        "add-two-numbers": "Grade-school addition from the ones digit, carrying until nothing is left.",
        "find-the-duplicate-number": "Values as pointers form a linked list with a cycle; Floyd finds its entrance, the duplicate.",
        "same-tree": "Equal roots, equal left subtrees, equal right subtrees.",
        "diameter-of-binary-tree": "At every node, the longest path through it is left height + right height.",
        "lowest-common-ancestor-of-a-binary-search-tree": "Walk down from the root until p and q fall on different sides.",
        "kth-smallest-element-in-a-bst": "In-order traversal visits a BST in sorted order; stop at the kth node.",
        "binary-tree-right-side-view": "BFS by level and keep the last node of each level.",
        "kth-largest-element-in-an-array": "A min-heap of size k keeps the k largest; its top is the answer.",
        "task-scheduler": "The most frequent task sets the frame: `(top - 1) · (n + 1) + ties`, at least `len(tasks)`.",
        "word-search": "DFS from every cell, marking the path while exploring and restoring it on the way back.",
        "letter-combinations-of-a-phone-number": "One recursion level per digit, one branch per letter.",
        "n-queens": "One queen per row, with sets for columns, `r - c` diagonals and `r + c` anti-diagonals.",
        "max-area-of-island": "A DFS that returns how many cells it sank.",
        "pacific-atlantic-water-flow": "Flow uphill from each ocean's edges and intersect what each ocean can reach.",
        "course-schedule-ii": "Kahn's algorithm: repeatedly take a course with no remaining prerequisites.",
        "cheapest-flights-within-k-stops": "Bellman-Ford for k + 1 rounds, relaxing from a copy of the previous round.",
        "min-cost-climbing-stairs": "Cost to stand on step i = min(from i-1, from i-2) plus the step you leave.",
        "house-robber-ii": "First and last can't both be robbed, so run House Robber twice, dropping one end each time.",
        "decode-ways": "Like Climbing Stairs: one digit or two digits at a time, if they're valid.",
        "word-break": "`dp[i]` is True if some word ends at i and `dp` at its start is True.",
        "longest-palindromic-substring": "Expand around all 2n - 1 centers.",
        "edit-distance": "Match: free diagonal step. Mismatch: 1 + min(insert, delete, replace).",
        "coin-change-ii": "Loop coins on the outside to count combinations, not orderings.",
        "gas-station": "If you run dry at i, no station between your start and i works; restart at i + 1.",
        "jump-game-ii": "BFS by levels: each jump extends the window to the farthest reachable index.",
        "insert-interval": "Copy intervals before it, absorb overlapping ones, then copy the rest.",
        "spiral-matrix": "Walk the four edges, pulling each boundary inward after you walk it.",
        "set-matrix-zeroes": "Find all zeros first, then clear; never clear while scanning.",
        "powx-n": "Square the base and halve the exponent: O(log n) multiplications.",
        "number-of-1-bits": "`n & (n - 1)` clears the lowest set bit.",
        "missing-number": "XOR all indices and values; the pairs cancel and the missing number remains.",
        "reverse-bits": "Pop bits off the right of n and push them onto the right of the result.",
    ]
}
