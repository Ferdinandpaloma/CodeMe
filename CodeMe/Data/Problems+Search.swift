import Foundation

extension ProblemBank {
    static let binarySearch: [Problem] = [
        Problem(
            id: "binary-search", number: 704, title: "Binary Search", difficulty: .easy, topic: .binarySearch,
            description: "Given a sorted (ascending) array of integers `nums` and a `target`, return the index of `target`, or `-1` if it doesn't exist.\n\nYour algorithm must run in O(log n) time.",
            examples: [ex("nums = [-1,0,3,5,9,12], target = 9", "4"), ex("nums = [-1,0,3,5,9,12], target = 2", "-1")],
            constraints: ["1 ≤ nums.length ≤ 10⁴", "All integers in nums are unique", "nums is sorted ascending"],
            hints: ["Compare the target with the middle element.", "Which half can you discard after one comparison?"],
            approach: ["Keep a search range `[l, r]`.", "Check the middle element. If it's the target, you're done.", "If the middle is too small, the target must be on the right (`l = mid + 1`); otherwise go left (`r = mid - 1`)."],
            solution: #"""
            class Solution:
                def search(self, nums: List[int], target: int) -> int:
                    l, r = 0, len(nums) - 1
                    while l <= r:
                        mid = (l + r) // 2
                        if nums[mid] == target:
                            return mid
                        if nums[mid] < target:
                            l = mid + 1
                        else:
                            r = mid - 1
                    return -1
            """#,
            time: "O(log n)", space: "O(1)"),

        Problem(
            id: "koko-eating-bananas", number: 875, title: "Koko Eating Bananas", difficulty: .medium, topic: .binarySearch,
            description: "Koko has `piles` of bananas and `h` hours. Each hour she picks one pile and eats `k` bananas from it (or the whole pile if it has fewer).\n\nReturn the **minimum integer speed** `k` that lets her finish every pile within `h` hours.",
            examples: [ex("piles = [3,6,7,11], h = 8", "4"), ex("piles = [30,11,23,4,20], h = 5", "30")],
            constraints: ["1 ≤ piles.length ≤ 10⁴", "piles.length ≤ h ≤ 10⁹", "1 ≤ piles[i] ≤ 10⁹"],
            hints: ["The answer lies between 1 and max(piles).", "If speed k works, every faster speed also works. That monotonic property is perfect for binary search."],
            approach: ["**Binary search on the answer**: the speed `k` in `[1, max(piles)]`.", "For a candidate `k`, total hours = sum of `ceil(pile / k)`.", "If it fits in `h`, try slower (`r = k`); otherwise go faster (`l = k + 1`)."],
            solution: #"""
            class Solution:
                def minEatingSpeed(self, piles: List[int], h: int) -> int:
                    l, r = 1, max(piles)
                    while l < r:
                        k = (l + r) // 2
                        hours = sum(math.ceil(p / k) for p in piles)
                        if hours <= h:
                            r = k  # k works, try slower
                        else:
                            l = k + 1
                    return l
            """#,
            time: "O(n log m)", space: "O(1)"),

        Problem(
            id: "search-in-rotated-sorted-array", number: 33, title: "Search in Rotated Sorted Array", difficulty: .medium, topic: .binarySearch,
            description: "A sorted array of unique integers was **rotated** at an unknown pivot, e.g. `[0,1,2,4,5,6,7]` became `[4,5,6,7,0,1,2]`.\n\nGiven the rotated array `nums` and a `target`, return its index or `-1`, in O(log n) time.",
            examples: [ex("nums = [4,5,6,7,0,1,2], target = 0", "4"), ex("nums = [4,5,6,7,0,1,2], target = 3", "-1"), ex("nums = [1], target = 0", "-1")],
            constraints: ["1 ≤ nums.length ≤ 5000", "All values are unique", "nums is an ascending array that may be rotated"],
            hints: ["After splitting at mid, at least one half is always sorted.", "Check whether the target lies inside the sorted half's range."],
            approach: ["Find `mid`. One of `[l..mid]` or `[mid..r]` is guaranteed to be **sorted**.", "If the left half is sorted and the target is within it, search left; otherwise search right.", "Mirror the logic when the right half is the sorted one."],
            solution: #"""
            class Solution:
                def search(self, nums: List[int], target: int) -> int:
                    l, r = 0, len(nums) - 1
                    while l <= r:
                        mid = (l + r) // 2
                        if nums[mid] == target:
                            return mid
                        if nums[l] <= nums[mid]:  # left half is sorted
                            if nums[l] <= target < nums[mid]:
                                r = mid - 1
                            else:
                                l = mid + 1
                        else:  # right half is sorted
                            if nums[mid] < target <= nums[r]:
                                l = mid + 1
                            else:
                                r = mid - 1
                    return -1
            """#,
            time: "O(log n)", space: "O(1)"),
    ]

    static let linkedList: [Problem] = [
        Problem(
            id: "reverse-linked-list", number: 206, title: "Reverse Linked List", difficulty: .easy, topic: .linkedList,
            description: "Given the `head` of a singly linked list, reverse the list and return the **new head**.",
            examples: [ex("head = [1,2,3,4,5]", "[5,4,3,2,1]"), ex("head = [1,2]", "[2,1]"), ex("head = []", "[]")],
            constraints: ["0 ≤ number of nodes ≤ 5000", "-5000 ≤ Node.val ≤ 5000"],
            hints: ["You need to flip each `next` pointer.", "Before overwriting `curr.next`, save where you were going."],
            approach: ["Keep `prev` (initially `None`) and `curr` (initially `head`).", "Save `curr.next`, point `curr.next` back to `prev`.", "Advance both pointers. When `curr` is `None`, `prev` is the new head."],
            solution: listNodeHeader + #"""
            class Solution:
                def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
                    prev, curr = None, head
                    while curr:
                        nxt = curr.next
                        curr.next = prev
                        prev, curr = curr, nxt
                    return prev
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "merge-two-sorted-lists", number: 21, title: "Merge Two Sorted Lists", difficulty: .easy, topic: .linkedList,
            description: "Merge two sorted linked lists `list1` and `list2` into one **sorted** list by splicing their nodes together. Return the head of the merged list.",
            examples: [ex("list1 = [1,2,4], list2 = [1,3,4]", "[1,1,2,3,4,4]"), ex("list1 = [], list2 = [0]", "[0]")],
            constraints: ["0 ≤ nodes in each list ≤ 50", "Both lists are sorted in non-decreasing order"],
            hints: ["A dummy head node removes edge cases for the first node.", "Always attach the smaller of the two current nodes."],
            approach: ["Create a **dummy** node and a `tail` pointer.", "While both lists have nodes, attach the smaller one to `tail` and advance it.", "Attach whatever remains, then return `dummy.next`."],
            solution: listNodeHeader + #"""
            class Solution:
                def mergeTwoLists(self, list1: Optional[ListNode], list2: Optional[ListNode]) -> Optional[ListNode]:
                    dummy = tail = ListNode()
                    while list1 and list2:
                        if list1.val < list2.val:
                            tail.next, list1 = list1, list1.next
                        else:
                            tail.next, list2 = list2, list2.next
                        tail = tail.next
                    tail.next = list1 or list2
                    return dummy.next
            """#,
            time: "O(n + m)", space: "O(1)"),

        Problem(
            id: "linked-list-cycle", number: 141, title: "Linked List Cycle", difficulty: .easy, topic: .linkedList,
            description: "Given `head`, determine whether the linked list contains a **cycle**: some node can be reached again by continuously following `next`.",
            examples: [ex("head = [3,2,0,-4], pos = 1", "true", "The tail connects back to the node at index 1."), ex("head = [1], pos = -1", "false")],
            constraints: ["0 ≤ number of nodes ≤ 10⁴", "pos is -1 or a valid index"],
            hints: ["A set of visited nodes works, but uses O(n) memory.", "If a fast runner laps a slow runner, the track must be a loop."],
            approach: ["Use **Floyd's tortoise and hare**: `slow` moves 1 step, `fast` moves 2.", "If there's a cycle, `fast` eventually lands on `slow`.", "If `fast` reaches the end, there's no cycle."],
            solution: listNodeHeader + #"""
            class Solution:
                def hasCycle(self, head: Optional[ListNode]) -> bool:
                    slow = fast = head
                    while fast and fast.next:
                        slow = slow.next
                        fast = fast.next.next
                        if slow is fast:
                            return True
                    return False
            """#,
            time: "O(n)", space: "O(1)"),

        Problem(
            id: "lru-cache", number: 146, title: "LRU Cache", difficulty: .medium, topic: .linkedList,
            description: "Design a **Least Recently Used** cache with a fixed `capacity`.\n\n• `get(key)` returns the value, or `-1` if missing.\n• `put(key, value)` inserts or updates. If the cache exceeds capacity, evict the least recently used key.\n\nBoth operations must run in O(1) average time.",
            examples: [ex(#"["LRUCache","put","put","get","put","get","put","get","get","get"]"# + "\n" + "[[2],[1,1],[2,2],[1],[3,3],[2],[4,4],[1],[3],[4]]", "[null,null,null,1,null,-1,null,-1,3,4]")],
            constraints: ["1 ≤ capacity ≤ 3000", "At most 2 · 10⁵ calls to get and put"],
            hints: ["A hash map gives O(1) lookup, but how do you track recency in O(1)?", "A doubly linked list can move a node to the front in O(1). Python's `OrderedDict` is exactly that combination."],
            approach: ["Combine a **hash map** with a **doubly linked list** ordered by recency (`OrderedDict` does both).", "On `get`, move the key to the most-recent end.", "On `put`, insert/update and move to the end; if over capacity, pop the least-recent item from the front."],
            solution: #"""
            class LRUCache:
                def __init__(self, capacity: int):
                    self.capacity = capacity
                    self.cache = OrderedDict()

                def get(self, key: int) -> int:
                    if key not in self.cache:
                        return -1
                    self.cache.move_to_end(key)  # mark as most recent
                    return self.cache[key]

                def put(self, key: int, value: int) -> None:
                    if key in self.cache:
                        self.cache.move_to_end(key)
                    self.cache[key] = value
                    if len(self.cache) > self.capacity:
                        self.cache.popitem(last=False)  # evict least recent
            """#,
            time: "O(1) per operation", space: "O(capacity)"),
    ]

    static let trees: [Problem] = [
        Problem(
            id: "invert-binary-tree", number: 226, title: "Invert Binary Tree", difficulty: .easy, topic: .trees,
            description: "Given the `root` of a binary tree, **mirror** it (swap every node's left and right children) and return its root.",
            examples: [ex("root = [4,2,7,1,3,6,9]", "[4,7,2,9,6,3,1]"), ex("root = [2,1,3]", "[2,3,1]"), ex("root = []", "[]")],
            constraints: ["0 ≤ number of nodes ≤ 100", "-100 ≤ Node.val ≤ 100"],
            hints: ["Inverting a tree = swap the children, then invert each subtree.", "What should happen for an empty tree?"],
            approach: ["Base case: an empty tree stays empty.", "Recursively invert the left and right subtrees.", "Assign them to the opposite sides and return the node."],
            solution: treeNodeHeader + #"""
            class Solution:
                def invertTree(self, root: Optional[TreeNode]) -> Optional[TreeNode]:
                    if not root:
                        return None
                    root.left, root.right = self.invertTree(root.right), self.invertTree(root.left)
                    return root
            """#,
            time: "O(n)", space: "O(h)"),

        Problem(
            id: "maximum-depth-of-binary-tree", number: 104, title: "Maximum Depth of Binary Tree", difficulty: .easy, topic: .trees,
            description: "Given the `root` of a binary tree, return its **maximum depth**: the number of nodes on the longest path from the root down to a leaf.",
            examples: [ex("root = [3,9,20,null,null,15,7]", "3"), ex("root = [1,null,2]", "2")],
            constraints: ["0 ≤ number of nodes ≤ 10⁴", "-100 ≤ Node.val ≤ 100"],
            hints: ["The depth of a tree is 1 + the deeper of its two subtrees."],
            approach: ["An empty tree has depth 0.", "Otherwise depth is `1 + max(depth(left), depth(right))`."],
            solution: treeNodeHeader + #"""
            class Solution:
                def maxDepth(self, root: Optional[TreeNode]) -> int:
                    if not root:
                        return 0
                    return 1 + max(self.maxDepth(root.left), self.maxDepth(root.right))
            """#,
            time: "O(n)", space: "O(h)"),

        Problem(
            id: "binary-tree-level-order-traversal", number: 102, title: "Binary Tree Level Order Traversal", difficulty: .medium, topic: .trees,
            description: "Given the `root` of a binary tree, return the node values **level by level**, left to right.",
            examples: [ex("root = [3,9,20,null,null,15,7]", "[[3],[9,20],[15,7]]"), ex("root = [1]", "[[1]]"), ex("root = []", "[]")],
            constraints: ["0 ≤ number of nodes ≤ 2000", "-1000 ≤ Node.val ≤ 1000"],
            hints: ["Breadth-first search visits nodes level by level.", "At the start of each level, the queue holds exactly that level's nodes."],
            approach: ["Use a **queue** starting with the root.", "For each level, pop exactly `len(queue)` nodes, recording their values.", "Push each popped node's children for the next level."],
            solution: treeNodeHeader + #"""
            class Solution:
                def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
                    if not root:
                        return []
                    result = []
                    queue = deque([root])
                    while queue:
                        level = []
                        for _ in range(len(queue)):
                            node = queue.popleft()
                            level.append(node.val)
                            if node.left:
                                queue.append(node.left)
                            if node.right:
                                queue.append(node.right)
                        result.append(level)
                    return result
            """#,
            time: "O(n)", space: "O(n)"),

        Problem(
            id: "validate-binary-search-tree", number: 98, title: "Validate Binary Search Tree", difficulty: .medium, topic: .trees,
            description: "Given the `root` of a binary tree, determine whether it is a valid **binary search tree**: every node in a left subtree is smaller than the node, and every node in a right subtree is larger.",
            examples: [ex("root = [2,1,3]", "true"), ex("root = [5,1,4,null,null,3,6]", "false", "The root is 5, but its right child is 4.")],
            constraints: ["1 ≤ number of nodes ≤ 10⁴", "-2³¹ ≤ Node.val ≤ 2³¹ - 1"],
            hints: ["Checking only parent vs child isn't enough. The whole subtree must respect ancestors.", "Pass down the allowed (low, high) range for each node."],
            approach: ["Each node must lie strictly within a range `(low, high)`.", "Going left, the upper bound becomes the node's value; going right, the lower bound does.", "Start with `(-inf, inf)` at the root."],
            solution: treeNodeHeader + #"""
            class Solution:
                def isValidBST(self, root: Optional[TreeNode]) -> bool:
                    def valid(node, low, high):
                        if not node:
                            return True
                        if not (low < node.val < high):
                            return False
                        return valid(node.left, low, node.val) and valid(node.right, node.val, high)

                    return valid(root, float("-inf"), float("inf"))
            """#,
            time: "O(n)", space: "O(h)"),

        Problem(
            id: "binary-tree-maximum-path-sum", number: 124, title: "Binary Tree Maximum Path Sum", difficulty: .hard, topic: .trees,
            description: "A **path** is any sequence of adjacent nodes in a tree where each node appears at most once; it doesn't need to pass through the root.\n\nGiven the `root`, return the maximum sum of any non-empty path.",
            examples: [ex("root = [1,2,3]", "6", "Path 2 → 1 → 3."), ex("root = [-10,9,20,null,null,15,7]", "42", "Path 15 → 20 → 7.")],
            constraints: ["1 ≤ number of nodes ≤ 3 · 10⁴", "-1000 ≤ Node.val ≤ 1000"],
            hints: ["At each node, a path can bend (use both children) or continue upward (use one child).", "Negative branches should be dropped by treating them as 0."],
            approach: ["DFS returns the best **one-sided** path starting at a node going down.", "At each node, consider the path that **bends** here: `val + left + right`, and update the global best.", "Return `val + max(left, right)` to the parent, clamping negative gains to 0."],
            solution: treeNodeHeader + #"""
            class Solution:
                def maxPathSum(self, root: Optional[TreeNode]) -> int:
                    best = root.val

                    def gain(node):
                        nonlocal best
                        if not node:
                            return 0
                        left = max(gain(node.left), 0)   # drop negative paths
                        right = max(gain(node.right), 0)
                        best = max(best, node.val + left + right)  # path bends here
                        return node.val + max(left, right)         # path continues up

                    gain(root)
                    return best
            """#,
            time: "O(n)", space: "O(h)"),
    ]

    static let tries: [Problem] = [
        Problem(
            id: "implement-trie-prefix-tree", number: 208, title: "Implement Trie (Prefix Tree)", difficulty: .medium, topic: .tries,
            description: "Implement a **Trie** with these methods:\n\n• `insert(word)` adds a word.\n• `search(word)` returns `true` if the exact word was inserted.\n• `startsWith(prefix)` returns `true` if any inserted word starts with `prefix`.",
            examples: [ex(#"["Trie","insert","search","search","startsWith","insert","search"]"# + "\n" + #"[[],["apple"],["apple"],["app"],["app"],["app"],["app"]]"#, "[null,null,true,false,true,null,true]")],
            constraints: ["1 ≤ word.length, prefix.length ≤ 2000", "Lowercase English letters only", "At most 3 · 10⁴ calls"],
            hints: ["Each node maps a character to a child node.", "You need a flag to mark where a complete word ends."],
            approach: ["Each `TrieNode` holds a `children` dict and an `is_end` flag.", "`insert` walks/creates a node per character, then marks the last node as an end.", "`search` and `startsWith` share a helper that walks the path; `search` also requires `is_end`."],
            solution: #"""
            class TrieNode:
                def __init__(self):
                    self.children = {}
                    self.is_end = False


            class Trie:
                def __init__(self):
                    self.root = TrieNode()

                def insert(self, word: str) -> None:
                    node = self.root
                    for c in word:
                        node = node.children.setdefault(c, TrieNode())
                    node.is_end = True

                def search(self, word: str) -> bool:
                    node = self._find(word)
                    return node is not None and node.is_end

                def startsWith(self, prefix: str) -> bool:
                    return self._find(prefix) is not None

                def _find(self, s):
                    node = self.root
                    for c in s:
                        if c not in node.children:
                            return None
                        node = node.children[c]
                    return node
            """#,
            time: "O(L) per operation", space: "O(total characters)",
            starterOverride: #"""
            class Trie:
                def __init__(self):
                    pass

                def insert(self, word: str) -> None:
                    pass

                def search(self, word: str) -> bool:
                    pass

                def startsWith(self, prefix: str) -> bool:
                    pass

            """#),

        Problem(
            id: "design-add-and-search-words-data-structure", number: 211, title: "Design Add and Search Words", difficulty: .medium, topic: .tries,
            description: "Design a structure that supports adding words and searching for them, where a search pattern may contain `.` which matches **any single letter**.",
            examples: [ex(#"addWord("bad"), addWord("dad"), addWord("mad")"# + "\n" + #"search("pad"), search("bad"), search(".ad"), search("b..")"#, "false, true, true, true")],
            constraints: ["1 ≤ word.length ≤ 25", "Search words contain at most 2 dots", "At most 10⁴ calls"],
            hints: ["Store the words in a trie.", "When you hit a `.`, try every child branch, which is a DFS."],
            approach: ["Insert words into a trie (here nested dicts with `$` marking word ends).", "Search with **DFS** over `(index, node)`.", "A letter follows one child; a `.` tries all children and succeeds if any branch matches."],
            solution: #"""
            class WordDictionary:
                def __init__(self):
                    self.root = {}

                def addWord(self, word: str) -> None:
                    node = self.root
                    for c in word:
                        node = node.setdefault(c, {})
                    node["$"] = True  # end-of-word marker

                def search(self, word: str) -> bool:
                    def dfs(i, node):
                        if i == len(word):
                            return "$" in node
                        c = word[i]
                        if c == ".":
                            return any(
                                dfs(i + 1, child)
                                for key, child in node.items()
                                if key != "$"
                            )
                        return c in node and dfs(i + 1, node[c])

                    return dfs(0, self.root)
            """#,
            time: "O(L) add, O(26ᵈ · L) search", space: "O(total characters)"),
    ]
}
