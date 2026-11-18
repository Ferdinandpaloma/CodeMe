import Foundation

struct TracePointer: Hashable {
    let label: String
    let index: Int
}

struct TraceVar: Hashable {
    let name: String
    let value: String
}

struct TracePanel: Hashable {
    let title: String
    let items: [String]
}

/// One frame of an algorithm walkthrough.
struct TraceStep {
    var cells: [String]
    var pointers: [TracePointer] = []
    var window: ClosedRange<Int>? = nil
    var active: Set<Int> = []
    var dimmed: Set<Int> = []
    var found: Set<Int> = []
    var vars: [TraceVar] = []
    var panels: [TracePanel] = []
    /// 1-based line in the problem's solution code.
    var line: Int
    var note: String
}

struct Walkthrough {
    let input: String
    let steps: [TraceStep]
}

/// Generates step-by-step traces by actually running each algorithm on a sample input.
enum Walkthroughs {
    static let available: Set<String> = [
        "two-sum", "valid-parentheses", "binary-search", "container-with-most-water",
        "best-time-to-buy-and-sell-stock", "longest-substring-without-repeating-characters",
        "daily-temperatures", "maximum-subarray", "house-robber",
        "product-of-array-except-self", "two-sum-ii-input-array-is-sorted", "find-minimum-in-rotated-sorted-array",
        "trapping-rain-water", "climbing-stairs", "coin-change", "valid-palindrome",
    ]

    static func make(for problem: Problem) -> Walkthrough? {
        switch problem.id {
        case "two-sum": twoSum()
        case "valid-parentheses": validParentheses()
        case "binary-search": binarySearch()
        case "container-with-most-water": container()
        case "best-time-to-buy-and-sell-stock": bestTime()
        case "longest-substring-without-repeating-characters": longestSubstring()
        case "daily-temperatures": dailyTemperatures()
        case "maximum-subarray": maxSubarray()
        case "house-robber": houseRobber()
        case "product-of-array-except-self": productExceptSelf()
        case "two-sum-ii-input-array-is-sorted": twoSumSorted()
        case "find-minimum-in-rotated-sorted-array": findMinRotated()
        case "trapping-rain-water": trappingRainWater()
        case "climbing-stairs": climbingStairs()
        case "coin-change": coinChange()
        case "valid-palindrome": validPalindrome()
        default: nil
        }
    }

    private static func v(_ name: String, _ value: Any) -> TraceVar { TraceVar(name: name, value: "\(value)") }
    private static func p(_ label: String, _ index: Int) -> TracePointer { TracePointer(label: label, index: index) }

    // MARK: Two Sum

    private static func twoSum() -> Walkthrough {
        let nums = [3, 5, 2, 8, 4], target = 12
        let cells = nums.map(String.init)
        var steps: [TraceStep] = []
        var index: [Int: Int] = [:]
        var order: [Int] = []
        func panels() -> [TracePanel] { [TracePanel(title: "index  (value → i)", items: order.map { "\($0) → \(index[$0]!)" })] }

        steps.append(TraceStep(cells: cells, vars: [v("target", target)], panels: panels(), line: 3,
                               note: "Start with an empty hash map from **value → index**."))
        for (i, n) in nums.enumerated() {
            let diff = target - n
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], active: [i], vars: [v("n", n), v("diff", diff)], panels: panels(), line: 6,
                                   note: "`diff = \(target) - \(n) = \(diff)`. Have we already seen **\(diff)**?"))
            if let j = index[diff] {
                steps.append(TraceStep(cells: cells, pointers: [p("j", j), p("i", i)], found: [j, i], vars: [v("n", n), v("diff", diff)], panels: panels(), line: 7,
                                       note: "Yes! \(diff) was stored at index \(j). Return `[\(j), \(i)]` in a single pass."))
                break
            }
            index[n] = i
            order.append(n)
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], active: [i], vars: [v("n", n), v("diff", diff)], panels: panels(), line: 8,
                                   note: "Not yet. Store `\(n) → \(i)` so later numbers can find it."))
        }
        return Walkthrough(input: "nums = [3,5,2,8,4], target = 12", steps: steps)
    }

    // MARK: Valid Parentheses

    private static func validParentheses() -> Walkthrough {
        let chars = Array("({[]})").map(String.init)
        let pairs = [")": "(", "]": "[", "}": "{"]
        var stack: [String] = []
        var done: Set<Int> = []
        var steps: [TraceStep] = []
        func panels() -> [TracePanel] { [TracePanel(title: "stack (bottom → top)", items: stack)] }

        steps.append(TraceStep(cells: chars, panels: panels(), line: 4, note: "Openers wait on a **stack** until their closer arrives."))
        for (i, c) in chars.enumerated() {
            if let opener = pairs[c] {
                stack.removeLast()
                done.insert(i)
                if let match = (0..<i).last(where: { chars[$0] == opener && !done.contains($0) }) { done.insert(match) }
                steps.append(TraceStep(cells: chars, pointers: [p("c", i)], active: [i], found: done, panels: panels(), line: 9,
                                       note: "`\(c)` matches the top of the stack, `\(opener)`. Pop it."))
            } else {
                stack.append(c)
                steps.append(TraceStep(cells: chars, pointers: [p("c", i)], active: [i], found: done, panels: panels(), line: 11,
                                       note: "`\(c)` is an opener. Push it and wait for its match."))
            }
        }
        steps.append(TraceStep(cells: chars, found: done, panels: panels(), line: 12,
                               note: "The stack is empty, so every bracket was closed in order. Return **True**."))
        return Walkthrough(input: #"s = "({[]})""#, steps: steps)
    }

    // MARK: Binary Search

    private static func binarySearch() -> Walkthrough {
        let nums = [-1, 0, 3, 5, 9, 12], target = 9
        let cells = nums.map(String.init)
        var steps: [TraceStep] = []
        var l = 0, r = nums.count - 1, checks = 0
        func outside(_ l: Int, _ r: Int) -> Set<Int> {
            l <= r ? Set(nums.indices).subtracting(l...r) : Set(nums.indices)
        }

        steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, vars: [v("target", target)], line: 3,
                               note: "The target could be anywhere: `l = 0`, `r = \(r)`."))
        while l <= r {
            let mid = (l + r) / 2
            checks += 1
            steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("mid", mid), p("r", r)], window: l...r, active: [mid], dimmed: outside(l, r),
                                   vars: [v("target", target), v("mid", mid), v("nums[mid]", nums[mid])], line: 5,
                                   note: "`mid = (\(l) + \(r)) // 2 = \(mid)`, and `nums[mid]` is **\(nums[mid])**."))
            if nums[mid] == target {
                steps.append(TraceStep(cells: cells, pointers: [p("mid", mid)], dimmed: outside(mid, mid), found: [mid], vars: [v("target", target), v("mid", mid)], line: 7,
                                       note: "\(nums[mid]) == \(target). Found it at index **\(mid)** after just \(checks) checks."))
                break
            }
            if nums[mid] < target {
                l = mid + 1
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, dimmed: outside(l, r), vars: [v("target", target)], line: 9,
                                       note: "\(nums[mid]) < \(target), so everything up to mid is too small. Move `l` to \(l)."))
            } else {
                r = mid - 1
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l <= r ? l...r : nil, dimmed: outside(l, r), vars: [v("target", target)], line: 11,
                                       note: "\(nums[mid]) > \(target), so everything from mid on is too big. Move `r` to \(r)."))
            }
        }
        return Walkthrough(input: "nums = [-1,0,3,5,9,12], target = 9", steps: steps)
    }

    // MARK: Container With Most Water

    private static func container() -> Walkthrough {
        let h = [1, 8, 6, 2, 5, 4, 8, 3, 7]
        let cells = h.map(String.init)
        var steps: [TraceStep] = []
        var l = 0, r = h.count - 1, best = 0
        var bestPair: Set<Int> = []

        steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, vars: [v("best", 0)], line: 3,
                               note: "Start with the **widest** container: both ends."))
        while l < r {
            let area = (r - l) * min(h[l], h[r])
            if area > best { best = area; bestPair = [l, r] }
            let moveLeft = h[l] < h[r]
            steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, active: [l, r],
                                   vars: [v("width", r - l), v("area", area), v("best", best)], line: moveLeft ? 9 : 11,
                                   note: "Area = \(r - l) × min(\(h[l]), \(h[r])) = **\(area)**. Move the shorter side (`\(moveLeft ? "l" : "r")`), because keeping it can never give a bigger area."))
            if moveLeft { l += 1 } else { r -= 1 }
        }
        steps.append(TraceStep(cells: cells, found: bestPair, vars: [v("best", best)], line: 12,
                               note: "The pointers met. The largest container holds **\(best)** units of water."))
        return Walkthrough(input: "height = [1,8,6,2,5,4,8,3,7]", steps: steps)
    }

    // MARK: Best Time to Buy and Sell Stock

    private static func bestTime() -> Walkthrough {
        let prices = [7, 1, 5, 3, 6, 4]
        let cells = prices.map(String.init)
        var steps: [TraceStep] = []
        var lowest = prices[0], lowIdx = 0, profit = 0, buy = 0, sell = 0

        steps.append(TraceStep(cells: cells, vars: [v("lowest", lowest), v("profit", profit)], line: 3,
                               note: "Track the **lowest price so far** (the best day to have bought) and the best profit."))
        for (i, price) in prices.enumerated() {
            let newLow = price < lowest
            if newLow { lowest = price; lowIdx = i }
            let gain = price - lowest
            if gain > profit { profit = gain; buy = lowIdx; sell = i }
            let note = (newLow || i == 0)
                ? "\(price) is the lowest price so far, the best day to buy."
                : "Selling today earns \(price) - \(lowest) = **\(gain)**. Best profit: \(profit)."
            steps.append(TraceStep(cells: cells, pointers: [p("buy", lowIdx), p("day", i)], window: lowIdx...i, active: [i],
                                   vars: [v("price", price), v("lowest", lowest), v("profit", profit)], line: newLow || i == 0 ? 6 : 7, note: note))
        }
        steps.append(TraceStep(cells: cells, pointers: [p("buy", buy), p("sell", sell)], found: [buy, sell], vars: [v("profit", profit)], line: 8,
                               note: "Buy at \(prices[buy]) and sell at \(prices[sell]) for a profit of **\(profit)**."))
        return Walkthrough(input: "prices = [7,1,5,3,6,4]", steps: steps)
    }

    // MARK: Longest Substring Without Repeating Characters

    private static func longestSubstring() -> Walkthrough {
        let s = Array("abcabcbb").map(String.init)
        var steps: [TraceStep] = []
        var window = Set<String>()
        var l = 0, best = 0, bestRange = 0...0
        func panel(_ upTo: Int) -> [TracePanel] { [TracePanel(title: "window set", items: l < upTo ? Array(s[l..<upTo]) : [])] }

        steps.append(TraceStep(cells: s, vars: [v("best", 0)], panels: panel(0), line: 3, note: "Start with an empty window: `l = 0`."))
        for r in s.indices {
            while window.contains(s[r]) {
                steps.append(TraceStep(cells: s, pointers: [p("l", l), p("r", r)], window: l <= r - 1 ? l...(r - 1) : nil, active: [r], dimmed: Set(0..<l),
                                       vars: [v("best", best)], panels: panel(r), line: 7,
                                       note: "'\(s[r])' is already in the window. Shrink it from the left."))
                window.remove(s[l])
                l += 1
                steps.append(TraceStep(cells: s, pointers: [p("l", l), p("r", r)], window: l <= r - 1 ? l...(r - 1) : nil, active: [r], dimmed: Set(0..<l),
                                       vars: [v("best", best)], panels: panel(r), line: 9,
                                       note: "Removed '\(s[l - 1])' and moved `l` to \(l)."))
            }
            window.insert(s[r])
            let length = r - l + 1
            if length > best { best = length; bestRange = l...r }
            steps.append(TraceStep(cells: s, pointers: [p("l", l), p("r", r)], window: l...r, active: [r], dimmed: Set(0..<l),
                                   vars: [v("length", length), v("best", best)], panels: panel(r + 1), line: 11,
                                   note: "Add '\(s[r])'. Window \"\(s[l...r].joined())\" has length \(length), and best is **\(best)**."))
        }
        steps.append(TraceStep(cells: s, found: Set(bestRange), vars: [v("best", best)], line: 12,
                               note: "The longest substring without repeats is \"\(s[bestRange].joined())\", length **\(best)**."))
        return Walkthrough(input: #"s = "abcabcbb""#, steps: steps)
    }

    // MARK: Daily Temperatures

    private static func dailyTemperatures() -> Walkthrough {
        let temps = [73, 74, 75, 71, 69, 72, 76, 73]
        let cells = temps.map(String.init)
        var answer = Array(repeating: 0, count: temps.count)
        var stack: [Int] = []
        var resolved: Set<Int> = []
        var steps: [TraceStep] = []
        func panels() -> [TracePanel] {
            [TracePanel(title: "stack (day: temp)", items: stack.map { "\($0): \(temps[$0])°" }),
             TracePanel(title: "answer", items: answer.map(String.init))]
        }

        steps.append(TraceStep(cells: cells, panels: panels(), line: 3,
                               note: "Every answer starts at 0. The stack holds days **still waiting** for a warmer day."))
        for (i, t) in temps.enumerated() {
            while let top = stack.last, temps[top] < t {
                stack.removeLast()
                answer[top] = i - top
                resolved.insert(top)
                steps.append(TraceStep(cells: cells, pointers: [p("j", top), p("i", i)], active: [i], found: resolved, panels: panels(), line: 8,
                                       note: "\(t)° is warmer than \(temps[top])°, so day \(top) waited \(i) - \(top) = **\(i - top)** days. Pop it."))
            }
            stack.append(i)
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], active: [i], found: resolved, panels: panels(), line: 9,
                                   note: "Push day \(i) (\(t)°) to wait for a warmer day."))
        }
        steps.append(TraceStep(cells: cells, found: resolved, panels: panels(), line: 10,
                               note: "Days left on the stack never got warmer, so they keep 0. Each day was pushed and popped at most once: **O(n)**."))
        return Walkthrough(input: "temperatures = [73,74,75,71,69,72,76,73]", steps: steps)
    }

    // MARK: Maximum Subarray

    private static func maxSubarray() -> Walkthrough {
        let nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
        let cells = nums.map(String.init)
        var steps: [TraceStep] = []
        var best = nums[0], current = 0, start = 0, bestRange = 0...0

        steps.append(TraceStep(cells: cells, vars: [v("current", current), v("best", best)], line: 3,
                               note: "`best` starts at the first element, and `current` is the best sum ending at the current index."))
        for (i, n) in nums.enumerated() {
            let extended = current + n
            let restart = n > extended
            let previous = current
            if restart { current = n; start = i } else { current = extended }
            if current > best { best = current; bestRange = start...i }
            let note = restart
                ? "Restart at \(n): the previous sum (\(previous)) was negative and could only drag it down."
                : "Extend: `\(previous) + \(n) = \(current)`. Best so far: **\(best)**."
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], window: start...i, active: [i],
                                   vars: [v("current", current), v("best", best)], line: 6, note: note))
        }
        let sub = nums[bestRange].map(String.init).joined(separator: ", ")
        steps.append(TraceStep(cells: cells, found: Set(bestRange), vars: [v("best", best)], line: 8,
                               note: "The best subarray [\(sub)] sums to **\(best)**."))
        return Walkthrough(input: "nums = [-2,1,-3,4,-1,2,1,-5,4]", steps: steps)
    }

    // MARK: House Robber

    private static func houseRobber() -> Walkthrough {
        let nums = [2, 7, 9, 3, 1]
        let cells = nums.map(String.init)
        var steps: [TraceStep] = []
        var prev = 0, curr = 0
        var bests: [Int] = []

        steps.append(TraceStep(cells: cells, vars: [v("prev", 0), v("curr", 0)], line: 3,
                               note: "`prev` = best total up to two houses back, `curr` = best up to the previous house."))
        for (i, n) in nums.enumerated() {
            let rob = prev + n, skip = curr
            prev = curr
            curr = max(skip, rob)
            bests.append(curr)
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], active: [i],
                                   vars: [v("rob", rob), v("skip", skip), v("curr", curr)],
                                   panels: [TracePanel(title: "best total after each house", items: bests.map(String.init))], line: 5,
                                   note: "House \(i) holds \(n). Rob it: \(rob - n) + \(n) = \(rob). Skip it: \(skip). Keep **\(curr)**."))
        }
        steps.append(TraceStep(cells: cells, found: [0, 2, 4], vars: [v("curr", curr)], line: 6,
                               note: "The most you can rob is **\(curr)** (houses 0, 2 and 4)."))
        return Walkthrough(input: "nums = [2,7,9,3,1]", steps: steps)
    }

    // MARK: Product of Array Except Self

    private static func productExceptSelf() -> Walkthrough {
        let nums = [1, 2, 3, 4]
        let cells = nums.map(String.init)
        let n = nums.count
        var answer = Array(repeating: 1, count: n)
        var steps: [TraceStep] = []
        func panels() -> [TracePanel] { [TracePanel(title: "answer", items: answer.map(String.init))] }

        steps.append(TraceStep(cells: cells, panels: panels(), line: 4,
                               note: "`answer[i]` will be (product of everything **left** of i) × (product of everything **right** of i)."))
        var prefix = 1
        for i in 0..<n {
            answer[i] = prefix
            let before = prefix
            prefix *= nums[i]
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], window: i > 0 ? 0...(i - 1) : nil, active: [i],
                                   vars: [v("prefix", prefix)], panels: panels(), line: 7,
                                   note: i == 0 ? "Nothing is left of index 0, so `answer[0] = 1`. Then `prefix` becomes \(prefix)."
                                                : "Everything left of \(i) multiplies to **\(before)**, so `answer[\(i)] = \(before)`. Then `prefix` becomes \(prefix)."))
        }
        var suffix = 1
        steps.append(TraceStep(cells: cells, vars: [v("suffix", suffix)], panels: panels(), line: 9,
                               note: "Left products are in place. Now sweep **right to left** with a running `suffix`."))
        for i in stride(from: n - 1, through: 0, by: -1) {
            let before = suffix
            answer[i] *= suffix
            suffix *= nums[i]
            steps.append(TraceStep(cells: cells, pointers: [p("i", i)], window: i < n - 1 ? (i + 1)...(n - 1) : nil, active: [i],
                                   vars: [v("suffix", suffix)], panels: panels(), line: 11,
                                   note: "Everything right of \(i) multiplies to **\(before)**. `answer[\(i)] *= \(before)` gives **\(answer[i])**."))
        }
        steps.append(TraceStep(cells: cells, found: Set(0..<n), panels: panels(), line: 13,
                               note: "Done in two passes with no division: `[\(answer.map(String.init).joined(separator: ", "))]`."))
        return Walkthrough(input: "nums = [1,2,3,4]", steps: steps)
    }

    // MARK: Two Sum II

    private static func twoSumSorted() -> Walkthrough {
        let nums = [1, 3, 4, 5, 7, 10, 11], target = 9
        let cells = nums.map(String.init)
        var steps: [TraceStep] = []
        var l = 0, r = nums.count - 1

        steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, vars: [v("target", target)], line: 3,
                               note: "The array is sorted. Start with the smallest (`l`) and largest (`r`) values."))
        while l < r {
            let total = nums[l] + nums[r]
            if total == target {
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], found: [l, r], vars: [v("total", total), v("target", target)], line: 11,
                                       note: "\(nums[l]) + \(nums[r]) = \(target). Return the 1-based indices **[\(l + 1), \(r + 1)]**."))
                break
            }
            let tooBig = total > target
            steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, active: [l, r],
                                   vars: [v("total", total), v("target", target)], line: tooBig ? 7 : 9,
                                   note: tooBig ? "\(nums[l]) + \(nums[r]) = \(total) is **too big**. Only a smaller right value can help, so move `r` left."
                                                : "\(nums[l]) + \(nums[r]) = \(total) is **too small**. Only a bigger left value can help, so move `l` right."))
            if tooBig { r -= 1 } else { l += 1 }
        }
        return Walkthrough(input: "numbers = [1,3,4,5,7,10,11], target = 9", steps: steps)
    }

    // MARK: Find Minimum in Rotated Sorted Array

    private static func findMinRotated() -> Walkthrough {
        let nums = [4, 5, 6, 7, 0, 1, 2]
        let cells = nums.map(String.init)
        var steps: [TraceStep] = []
        var l = 0, r = nums.count - 1
        func outside(_ l: Int, _ r: Int) -> Set<Int> { Set(nums.indices).subtracting(l...r) }

        steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], window: l...r, line: 3,
                               note: "Somewhere the sorted order **drops**. The minimum sits right after the drop."))
        while l < r {
            let mid = (l + r) / 2
            let goRight = nums[mid] > nums[r]
            steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("mid", mid), p("r", r)], window: l...r, active: [mid, r], dimmed: outside(l, r),
                                   vars: [v("nums[mid]", nums[mid]), v("nums[r]", nums[r])], line: goRight ? 7 : 9,
                                   note: goRight ? "\(nums[mid]) > \(nums[r]): the drop is to the **right** of mid. `l = mid + 1`."
                                                 : "\(nums[mid]) ≤ \(nums[r]): mid..r is sorted, so the minimum is at mid or to its left. `r = mid`."))
            if goRight { l = mid + 1 } else { r = mid }
        }
        steps.append(TraceStep(cells: cells, pointers: [p("l", l)], dimmed: outside(l, l), found: [l], vars: [v("min", nums[l])], line: 10,
                               note: "`l == r`. The minimum is **\(nums[l])**, found in O(log n)."))
        return Walkthrough(input: "nums = [4,5,6,7,0,1,2]", steps: steps)
    }

    // MARK: Trapping Rain Water

    private static func trappingRainWater() -> Walkthrough {
        let h = [0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]
        let cells = h.map(String.init)
        var steps: [TraceStep] = []
        var l = 0, r = h.count - 1
        var leftMax = h[l], rightMax = h[r], water = 0
        var wet: Set<Int> = []

        steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], vars: [v("left_max", leftMax), v("right_max", rightMax), v("water", 0)], line: 4,
                               note: "Water above a bar = min(tallest on its left, tallest on its right) − its height."))
        while l < r {
            if leftMax < rightMax {
                l += 1
                leftMax = max(leftMax, h[l])
                let add = leftMax - h[l]
                water += add
                if add > 0 { wet.insert(l) }
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], active: [l], found: wet,
                                       vars: [v("left_max", leftMax), v("right_max", rightMax), v("water", water)], line: 10,
                                       note: "Left max (\(leftMax)) is the bottleneck, so bar \(l) holds \(leftMax) − \(h[l]) = **\(add)**."))
            } else {
                r -= 1
                rightMax = max(rightMax, h[r])
                let add = rightMax - h[r]
                water += add
                if add > 0 { wet.insert(r) }
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], active: [r], found: wet,
                                       vars: [v("left_max", leftMax), v("right_max", rightMax), v("water", water)], line: 14,
                                       note: "Right max (\(rightMax)) is the bottleneck, so bar \(r) holds \(rightMax) − \(h[r]) = **\(add)**."))
            }
        }
        steps.append(TraceStep(cells: cells, found: wet, vars: [v("water", water)], line: 15,
                               note: "The pointers met. Total trapped water: **\(water)** units."))
        return Walkthrough(input: "height = [0,1,0,2,1,0,1,3,2,1,2,1]", steps: steps)
    }

    // MARK: Climbing Stairs

    private static func climbingStairs() -> Walkthrough {
        let n = 6
        var ways = Array(repeating: "?", count: n + 1)
        ways[0] = "1"; ways[1] = "1"
        var steps: [TraceStep] = []
        var values = [1, 1]

        steps.append(TraceStep(cells: ways, found: [0, 1], vars: [v("one", 1), v("two", 1)], line: 3,
                               note: "One way to stand on step 0 (do nothing) and one way to reach step 1."))
        for i in 2...n {
            let value = values[i - 1] + values[i - 2]
            values.append(value)
            ways[i] = String(value)
            steps.append(TraceStep(cells: ways, pointers: [p("i", i)], window: (i - 2)...(i - 1), active: [i], found: Set(0..<i),
                                   vars: [v("one", value), v("two", values[i - 1])], line: 5,
                                   note: "Reach step \(i) from step \(i - 1) or step \(i - 2): \(values[i - 1]) + \(values[i - 2]) = **\(value)**."))
        }
        steps.append(TraceStep(cells: ways, found: Set(0...n), vars: [v("one", values[n])], line: 6,
                               note: "There are **\(values[n])** ways to climb \(n) stairs. It's the Fibonacci sequence!"))
        return Walkthrough(input: "n = 6  ·  cells: ways to reach step i", steps: steps)
    }

    // MARK: Coin Change

    private static func coinChange() -> Walkthrough {
        let coins = [1, 2, 5], amount = 11
        var dp = [0] + Array(repeating: Int.max, count: amount)
        func cells() -> [String] { dp.map { $0 == Int.max ? "∞" : String($0) } }
        var steps: [TraceStep] = []

        steps.append(TraceStep(cells: cells(), found: [0], vars: [v("coins", "[1, 2, 5]")], line: 3,
                               note: "`dp[a]` = fewest coins that make amount `a`. `dp[0] = 0`; everything else starts at ∞."))
        for a in 1...amount {
            var options: [String] = []
            for coin in coins where coin <= a && dp[a - coin] != Int.max {
                options.append("\(coin) + dp[\(a - coin)]")
                if dp[a - coin] + 1 < dp[a] { dp[a] = dp[a - coin] + 1 }
            }
            steps.append(TraceStep(cells: cells(), pointers: [p("a", a)], active: [a], dimmed: a < amount ? Set((a + 1)...amount) : [],
                                   vars: [v("a", a), v("dp[a]", dp[a])],
                                   panels: [TracePanel(title: "last coin options", items: options)], line: 7,
                                   note: "Try each coin as the **last** one: \(options.joined(separator: ", ")). Best is **\(dp[a])** coin\(dp[a] == 1 ? "" : "s")."))
        }
        steps.append(TraceStep(cells: cells(), found: [amount], vars: [v("dp[11]", dp[amount])], line: 8,
                               note: "11 = 5 + 5 + 1, so the answer is **\(dp[amount])** coins."))
        return Walkthrough(input: "coins = [1,2,5], amount = 11  ·  cells: dp[a]", steps: steps)
    }

    // MARK: Valid Palindrome

    private static func validPalindrome() -> Walkthrough {
        let raw = Array("Taco cat!")
        let cells = raw.map { $0 == " " ? "␣" : String($0) }
        var steps: [TraceStep] = []
        var l = 0, r = raw.count - 1
        var matched: Set<Int> = []
        var skipped: Set<Int> = []

        steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], line: 3,
                               note: "Compare from both ends, ignoring case and anything that isn't a letter or digit."))
        while l < r {
            while l < r && !(raw[l].isLetter || raw[l].isNumber) {
                skipped.insert(l)
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], active: [l], dimmed: skipped, found: matched, line: 5,
                                       note: "'\(cells[l])' isn't alphanumeric. Skip it."))
                l += 1
            }
            while l < r && !(raw[r].isLetter || raw[r].isNumber) {
                skipped.insert(r)
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], active: [r], dimmed: skipped, found: matched, line: 7,
                                       note: "'\(cells[r])' isn't alphanumeric. Skip it."))
                r -= 1
            }
            let a = raw[l].lowercased(), b = raw[r].lowercased()
            if a != b {
                steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], active: [l, r], dimmed: skipped, found: matched, line: 10,
                                       note: "'\(a)' ≠ '\(b)'. Not a palindrome."))
                return Walkthrough(input: #"s = "Taco cat!""#, steps: steps)
            }
            matched.formUnion([l, r])
            steps.append(TraceStep(cells: cells, pointers: [p("l", l), p("r", r)], active: [l, r], dimmed: skipped, found: matched, line: 11,
                                   note: "'\(raw[l])' and '\(raw[r])' match (ignoring case). Move both pointers inward."))
            l += 1
            r -= 1
        }
        steps.append(TraceStep(cells: cells, dimmed: skipped, found: matched, line: 12,
                               note: "The pointers met without a mismatch: **\"tacocat\"** is a palindrome."))
        return Walkthrough(input: #"s = "Taco cat!""#, steps: steps)
    }
}
