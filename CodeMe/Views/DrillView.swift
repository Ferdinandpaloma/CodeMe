import SwiftUI

enum DrillMode: String, Hashable {
    case fillBlank, lineOrder

    var title: String {
        switch self {
        case .fillBlank: "Fill the Blank"
        case .lineOrder: "Line Order"
        }
    }
}

/// Helpers that pull drill material out of solution code.
enum DrillBank {
    struct Line: Hashable {
        let number: Int   // 1-based line in the solution
        let text: String
        var trimmed: String { text.trimmingCharacters(in: .whitespaces) }
        var indent: Int { text.prefix { $0 == " " }.count }
    }

    static func lines(of problem: Problem) -> [Line] {
        problem.solution.components(separatedBy: "\n").enumerated().map { Line(number: $0.offset + 1, text: $0.element) }
    }

    /// Lines worth blanking out: real logic, not boilerplate.
    static func blankCandidates(in problem: Problem) -> [Line] {
        lines(of: problem).filter { line in
            let t = line.trimmed
            guard line.indent >= 8, t.count >= 8 else { return false }
            let boring = ["#", "else:", "return result", "return True", "return False", "continue", "break", "pass", "\"\"\""]
            return !boring.contains(where: { t.hasPrefix($0) }) && !t.hasPrefix("def ")
        }
    }

    static var fillBlankPool: [Problem] { ProblemBank.all.filter { blankCandidates(in: $0).count >= 2 } }

    /// The body of the first method (after its `def` line), skipping blanks.
    static func body(of problem: Problem) -> (header: [Line], body: [Line])? {
        let all = lines(of: problem)
        let defs = all.filter { $0.indent == 4 && $0.trimmed.hasPrefix("def ") }
        guard defs.count == 1, let def = defs.first, let defIndex = all.firstIndex(of: def) else { return nil }
        let header = Array(all[...defIndex]).filter { !$0.trimmed.isEmpty && !($0.indent == 0 && $0.trimmed.hasPrefix("#")) }
        let body = all[(defIndex + 1)...].filter { !$0.trimmed.isEmpty }
        return (header, Array(body))
    }

    static var lineOrderPool: [Problem] {
        ProblemBank.all.filter { problem in
            guard let parts = body(of: problem) else { return false }
            let texts = parts.body.map(\.text)
            return (4...9).contains(texts.count)
        }
    }
}

struct DrillView: View {
    let mode: DrillMode
    @Environment(ProgressStore.self) private var store

    @State private var problem: Problem = ProblemBank.all[0]
    @State private var score = 0
    @State private var answered = 0
    @State private var loaded = false

    // Fill the blank
    @State private var blank: DrillBank.Line?
    @State private var options: [String] = []
    @State private var picked: String?

    // Line order
    @State private var pool: [Tile] = []
    @State private var placed: [Tile] = []
    @State private var checked: Bool? = nil
    @State private var gaveUp = false

    struct Tile: Identifiable, Hashable {
        let id: Int        // position in the correct order
        let text: String
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                switch mode {
                case .fillBlank: fillBlank
                case .lineOrder: lineOrder
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(score)/\(answered)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .contentTransition(.numericText())
            }
        }
        .onAppear {
            if !loaded { next(); loaded = true }
        }
        .sensoryFeedback(trigger: answered) { _, _ in
            let correct = mode == .fillBlank ? picked == blank?.trimmed : checked == true
            return correct ? .success : .error
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            DifficultyPill(difficulty: problem.difficulty)
            TopicChip(topic: problem.topic)
            Spacer()
            NavigationLink(value: problem) {
                Text(problem.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }
        }
    }

    // MARK: Fill the blank

    private var blankedCode: String {
        guard let blank else { return problem.solution }
        return DrillBank.lines(of: problem).map { line in
            line.number == blank.number ? String(repeating: " ", count: line.indent) + "# ??? which line goes here?" : line.text
        }.joined(separator: "\n")
    }

    private var fillBlank: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pick the line that completes the solution.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            CodeBlockView(code: picked == nil ? blankedCode : problem.solution, highlightedLine: blank?.number)
                .id(problem.id + "\(picked != nil)")
            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    optionButton(option)
                }
            }
            if picked != nil {
                nextButton
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        let correct = blank?.trimmed
        let state: OptionState = {
            guard let picked else { return .idle }
            if option == correct { return .correct }
            if option == picked { return .wrong }
            return .dimmed
        }()
        return Button {
            guard picked == nil else { return }
            withAnimation(.spring(duration: 0.35)) {
                picked = option
                answered += 1
                if option == correct {
                    score += 1
                    store.recordDrillCorrect()
                }
            }
        } label: {
            HStack {
                Text(PythonHighlighter.highlightedLines(option).first ?? AttributedString(option))
                    .font(.system(size: 13, design: .monospaced))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                if state == .correct || state == .wrong {
                    Image(systemName: state == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .fontWeight(.semibold)
                        .foregroundStyle(state == .correct ? Theme.easy : Theme.hard)
                        .transition(.blurReplace)
                }
            }
            .padding(12)
            .background(CodeTheme.background, in: .rounded(Radius.outer(inner: 2, padding: 12)))
            .overlay(RoundedRectangle(cornerRadius: Radius.outer(inner: 2, padding: 12), style: .continuous)
                .strokeBorder(state == .correct ? Theme.easy : state == .wrong ? Theme.hard : CodeTheme.border, lineWidth: state == .idle || state == .dimmed ? 0.75 : 2))
            .opacity(state == .dimmed ? 0.45 : 1)
            .environment(\.colorScheme, .dark)
        }
        .buttonStyle(PressableStyle())
        .disabled(picked != nil)
    }

    // MARK: Line order

    private var lineOrder: some View {
        let parts = DrillBank.body(of: problem)
        return VStack(alignment: .leading, spacing: 14) {
            Text("Tap the lines in the right order to rebuild the solution. Indentation is a clue!")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FadingScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(parts?.header ?? [], id: \.self) { line in
                        codeLine(line.text)
                            .opacity(0.6)
                    }
                    ForEach(Array(placed.enumerated()), id: \.element.id) { index, tile in
                        Button {
                            guard checked != true else { return }
                            withAnimation(.snappy) {
                                placed.remove(at: index)
                                pool.append(tile)
                                checked = nil
                            }
                        } label: {
                            codeLine(tile.text)
                                .padding(.vertical, 4)
                                .padding(.trailing, 8)
                                .background(lineColor(index: index, tile: tile), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                    if placed.count < (parts?.body.count ?? 0) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(CodeTheme.border, style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 240, height: 28)
                    }
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CodeTheme.background, in: .rounded(Radius.outer(inner: 6, padding: 14)))
            .overlay(RoundedRectangle(cornerRadius: Radius.outer(inner: 6, padding: 14), style: .continuous).strokeBorder(CodeTheme.border, lineWidth: 0.75))
            .environment(\.colorScheme, .dark)

            if !pool.isEmpty {
                SectionHeader("Available lines", icon: "square.stack")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(pool) { tile in
                        Button {
                            withAnimation(.snappy) {
                                pool.removeAll { $0.id == tile.id }
                                placed.append(tile)
                                checked = nil
                            }
                        } label: {
                            HStack(spacing: 6) {
                                    // Indentation guide: one bar per level inside the method body.
                                    ForEach(0..<max(0, (tile.text.prefix { $0 == " " }.count - 8) / 4), id: \.self) { _ in
                                        Capsule().fill(CodeTheme.lineNumber.opacity(0.6)).frame(width: 2, height: 16)
                                    }
                                    Text(PythonHighlighter.highlightedLines(tile.text.trimmingCharacters(in: .whitespaces)).first ?? AttributedString(tile.text))
                                        .font(.system(size: 13, design: .monospaced))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(CodeTheme.background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(CodeTheme.border, lineWidth: 0.75))
                                .environment(\.colorScheme, .dark)
                        }
                        .buttonStyle(PressableStyle())
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
            }

            if let checked {
                Label(checked ? (gaveUp ? "Here's the correct order." : "Perfect order!") : "Not quite. Lines in red are out of place. Tap them to send them back.",
                      systemImage: checked ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(checked ? Theme.easy : Theme.hard)
            }

            if checked == true {
                if let insight = problem.insight { InsightCard(text: insight) }
                nextButton
            } else if pool.isEmpty {
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.snappy) { revealOrder() }
                    } label: {
                        Text("Show answer")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.elevated, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    Button {
                        withAnimation(.spring) { checkOrder() }
                    } label: {
                        Label("Check", systemImage: "checkmark")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    private func codeLine(_ text: String) -> some View {
        Text(PythonHighlighter.highlightedLines(text).first ?? AttributedString(text))
            .font(.system(size: 12.5, design: .monospaced))
            .lineLimit(1)
            .fixedSize()
    }

    private var correctTexts: [String] { DrillBank.body(of: problem)?.body.map(\.text) ?? [] }

    private func lineColor(index: Int, tile: Tile) -> Color {
        guard let checked else { return Color.white.opacity(0.04) }
        if checked { return Theme.easy.opacity(0.18) }
        return correctTexts.indices.contains(index) && correctTexts[index] == tile.text ? Theme.easy.opacity(0.18) : Theme.hard.opacity(0.28)
    }

    private func checkOrder() {
        let ok = placed.map(\.text) == correctTexts
        checked = ok
        answered += 1
        if ok {
            score += 1
            store.recordDrillCorrect()
        }
    }

    private func revealOrder() {
        let tiles = correctTexts.enumerated().map { Tile(id: $0.offset, text: $0.element) }
        placed = tiles
        pool = []
        gaveUp = true
        answered += 1
        checked = true
    }

    // MARK: Shared

    private var nextButton: some View {
        Button {
            withAnimation(.spring(duration: 0.45)) { next() }
        } label: {
            Label("Next", systemImage: "arrow.right")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: Radius.control + 2, style: .continuous))
        }
        .buttonStyle(PressableStyle())
    }

    private func next() {
        switch mode {
        case .fillBlank:
            let candidates = DrillBank.fillBlankPool.filter { $0 != problem }
            guard let choice = candidates.randomElement() else { return }
            problem = choice
            let lines = DrillBank.blankCandidates(in: choice)
            let answer = lines.randomElement()!
            blank = answer
            // Distractors: other lines from this solution plus lines from related solutions.
            var distractors = Set(lines.map(\.trimmed)).subtracting([answer.trimmed])
            for other in ProblemBank.problems(for: choice.topic).shuffled() where other != choice {
                distractors.formUnion(DrillBank.blankCandidates(in: other).map(\.trimmed))
            }
            let sameSolution = lines.map(\.trimmed).filter { $0 != answer.trimmed }.shuffled().prefix(1)
            let others = distractors.subtracting(sameSolution).shuffled().prefix(3 - sameSolution.count)
            options = ([answer.trimmed] + sameSolution + others).shuffled()
            picked = nil
        case .lineOrder:
            let candidates = DrillBank.lineOrderPool.filter { $0 != problem }
            guard let choice = candidates.randomElement(), let parts = DrillBank.body(of: choice) else { return }
            problem = choice
            let tiles = parts.body.enumerated().map { Tile(id: $0.offset, text: $0.element.text) }
            var shuffled = tiles.shuffled()
            while shuffled == tiles && tiles.count > 1 { shuffled.shuffle() }
            pool = shuffled
            placed = []
            checked = nil
            gaveUp = false
        }
    }
}
