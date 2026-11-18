import SwiftUI

enum ReferenceSheet: String, Hashable, CaseIterable, Identifiable {
    case bigO, python, patterns

    var id: Self { self }

    var title: String {
        switch self {
        case .bigO: "Big-O Cheat Sheet"
        case .python: "Python Cheat Sheet"
        case .patterns: "Patterns at a Glance"
        }
    }

    var subtitle: String {
        switch self {
        case .bigO: "Operation costs and what input sizes allow"
        case .python: "The standard library you'll use in interviews"
        case .patterns: "Every topic's signals and template in one place"
        }
    }

    var icon: String {
        switch self {
        case .bigO: "speedometer"
        case .python: "chevron.left.forwardslash.chevron.right"
        case .patterns: "square.grid.3x3.fill"
        }
    }

    var color: Color {
        switch self {
        case .bigO: Palette.pink.color
        case .python: Palette.blue.color
        case .patterns: Palette.teal.color
        }
    }
}

struct ReferenceView: View {
    let sheet: ReferenceSheet

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                switch sheet {
                case .bigO: bigO
                case .python: python
                case .patterns: patterns
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(sheet.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: Big-O

    private struct Row: Hashable {
        let op: String
        let cost: String
        var note: String = ""
    }

    private var bigO: some View {
        Group {
            table("Input size → target complexity", icon: "ruler", headers: ("n up to", "Aim for"), rows: [
                Row(op: "10", cost: "O(n!)", note: "permutations"),
                Row(op: "20", cost: "O(2ⁿ)", note: "subsets, bitmask"),
                Row(op: "500", cost: "O(n³)", note: "triple loop / interval DP"),
                Row(op: "10⁴", cost: "O(n²)", note: "double loop, 2-D DP"),
                Row(op: "10⁶", cost: "O(n log n)", note: "sort, heap"),
                Row(op: "10⁸", cost: "O(n)", note: "one pass"),
                Row(op: "beyond", cost: "O(log n) / O(1)", note: "binary search, math"),
            ])
            table("list", icon: "list.number", headers: ("Operation", "Cost"), rows: [
                Row(op: "a[i], a[i] = x, len(a)", cost: "O(1)"),
                Row(op: "a.append(x), a.pop()", cost: "O(1)", note: "amortized"),
                Row(op: "a.pop(0), a.insert(0, x)", cost: "O(n)", note: "use deque"),
                Row(op: "x in a, a.index(x)", cost: "O(n)"),
                Row(op: "a[i:j], a.copy()", cost: "O(k)"),
                Row(op: "a.sort(), sorted(a)", cost: "O(n log n)"),
            ])
            table("dict / set", icon: "number", headers: ("Operation", "Cost"), rows: [
                Row(op: "d[k], d[k] = v, k in d", cost: "O(1)", note: "average"),
                Row(op: "del d[k], s.add(x)", cost: "O(1)"),
                Row(op: "s1 & s2, s1 | s2", cost: "O(len)"),
                Row(op: "iterate", cost: "O(n)"),
            ])
            table("deque / heapq / bisect", icon: "arrow.left.arrow.right", headers: ("Operation", "Cost"), rows: [
                Row(op: "q.append, q.appendleft", cost: "O(1)"),
                Row(op: "q.pop, q.popleft", cost: "O(1)"),
                Row(op: "heappush, heappop", cost: "O(log n)"),
                Row(op: "heap[0] (peek min)", cost: "O(1)"),
                Row(op: "heapify(list)", cost: "O(n)"),
                Row(op: "bisect_left / right", cost: "O(log n)"),
            ])
            table("Algorithms", icon: "function", headers: ("Algorithm", "Time"), rows: [
                Row(op: "Binary search", cost: "O(log n)"),
                Row(op: "BFS / DFS", cost: "O(V + E)"),
                Row(op: "Dijkstra (heap)", cost: "O(E log V)"),
                Row(op: "Topological sort", cost: "O(V + E)"),
                Row(op: "Union-Find (both opts)", cost: "≈ O(1)", note: "per op"),
                Row(op: "Merge / heap / Timsort", cost: "O(n log n)"),
            ])
        }
    }

    private func table(_ title: String, icon: String, headers: (String, String), rows: [Row]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title, icon: icon)
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 9) {
                GridRow {
                    Text(headers.0)
                    Text(headers.1)
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                Divider()
                ForEach(rows, id: \.self) { row in
                    GridRow {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.op).font(.footnote.monospaced())
                            if !row.note.isEmpty {
                                Text(row.note).font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        Text(row.cost)
                            .font(.footnote.monospaced().weight(.bold))
                            .foregroundStyle(costColor(row.cost))
                    }
                }
            }
        }
        .card()
    }

    private func costColor(_ cost: String) -> Color {
        if cost.contains("!") || cost.contains("ⁿ") || cost.contains("³") || cost.contains("²") { return Theme.hard }
        if cost.contains("n log") || cost.contains("O(n)") || cost.contains("len") || cost.contains("V + E") || cost.contains("O(k)") || cost.contains("E log") { return Theme.medium }
        return Theme.easy
    }

    // MARK: Python

    private static let pythonSections: [(String, String, String)] = [
        ("Hash maps & counting", "number", #"""
        from collections import Counter, defaultdict

        count = Counter("banana")       # {'a': 3, 'n': 2, 'b': 1}
        count.most_common(2)            # [('a', 3), ('n', 2)]
        groups = defaultdict(list)
        groups[key].append(value)       # no KeyError
        seen = {}
        seen[x] = seen.get(x, 0) + 1
        """#),
        ("Stacks & queues", "square.stack.3d.up", #"""
        stack = []
        stack.append(x); top = stack[-1]; stack.pop()

        from collections import deque
        q = deque([start])
        q.append(x); q.popleft()        # O(1) both ends
        """#),
        ("Heaps (min-heap)", "triangle", #"""
        import heapq

        heap = []
        heapq.heappush(heap, (dist, node))
        dist, node = heapq.heappop(heap)
        heapq.heapify(nums)             # O(n)
        heapq.heappush(heap, -x)        # max-heap: negate
        heapq.nlargest(k, nums)
        """#),
        ("Sorting & binary search", "arrow.up.arrow.down", #"""
        nums.sort()                      # in place
        pairs.sort(key=lambda p: (p[0], -p[1]))
        words = sorted(words, key=len, reverse=True)

        from bisect import bisect_left, insort
        i = bisect_left(nums, target)    # first index >= target
        insort(nums, x)                  # keep sorted
        """#),
        ("Strings", "textformat", #"""
        s.isalnum(); s.isdigit(); s.lower()
        "".join(chars)                   # build strings with join
        s[::-1]                          # reversed copy
        ord(c) - ord("a")                # letter -> 0..25
        chr(ord("a") + i)
        s.split(), " ".join(words)
        """#),
        ("Loops & comprehensions", "repeat", #"""
        for i, x in enumerate(nums): ...
        for a, b in zip(xs, ys): ...
        for i in range(n - 1, -1, -1): ...   # backwards

        squares = [x * x for x in nums if x > 0]
        grid = [[0] * cols for _ in range(rows)]  # NOT [[0]*cols]*rows
        index = {v: i for i, v in enumerate(nums)}
        """#),
        ("Recursion & memoization", "arrow.triangle.branch", #"""
        from functools import cache

        @cache
        def dp(i, j):
            if i == len(s):
                return 0
            return max(dp(i + 1, j), dp(i, j + 1))

        import sys
        sys.setrecursionlimit(10**6)
        """#),
        ("Numbers & bits", "function", #"""
        float("inf"), float("-inf")
        7 // 2 == 3; -7 // 2 == -4       # floors!
        int(-7 / 2) == -3                # truncate toward 0
        q, r = divmod(17, 5)
        x & 1; x >> 1; x << 1; x ^ y
        n & (n - 1)                      # clear lowest set bit
        bin(n).count("1")
        """#),
    ]

    private var python: some View {
        ForEach(Self.pythonSections, id: \.0) { title, icon, code in
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title, icon: icon)
                CodeBlockView(code: code, fileName: "cheatsheet.py")
            }
        }
    }

    // MARK: Patterns

    private var patterns: some View {
        ForEach(Topic.allCases) { topic in
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(topic.signals, id: \.self) { signal in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: "sparkle").font(.caption.weight(.semibold)).foregroundStyle(topic.color)
                            MarkdownText(signal).font(.subheadline)
                        }
                    }
                    CodeBlockView(code: topic.template, fileName: "template.py")
                    NavigationLink(value: topic) {
                        Label("Open topic", systemImage: "arrow.right.circle.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .padding(.top, 10)
            } label: {
                HStack(spacing: 12) {
                    TopicIcon(topic: topic, size: 34)
                    Text(topic.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            .tint(.secondary)
            .card(padding: 14)
        }
    }
}

struct ReferenceCard: View {
    let sheet: ReferenceSheet

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: sheet.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(sheet.color.oklchGradient, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(sheet.title).font(.headline).foregroundStyle(.primary)
                Text(sheet.subtitle).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").font(.footnote.weight(.bold)).foregroundStyle(.tertiary)
        }
        .card(padding: 14)
    }
}
