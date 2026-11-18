import SwiftUI

struct ProblemDetailView: View {
    let problem: Problem
    @Environment(ProgressStore.self) private var store

    @State private var tab: DetailTab = .problem
    @State private var hintsShown = 0
    @State private var solutionRevealed = false
    @State private var showSolutionSheet = false
    @State private var confirmReset = false
    @State private var showWalkthrough = false
    @State private var noteDraft = ""
    @FocusState private var noteFocused: Bool

    @AppStorage(SettingsKey.lockSolutions) private var lockSolutions = true
    @AppStorage(SettingsKey.editorFontSize) private var fontSize = SettingsKey.defaultFontSize
    @AppStorage(SettingsKey.autoPair) private var autoPair = true

    enum DetailTab: String, CaseIterable, Identifiable {
        case problem = "Problem"
        case solution = "Solution"
        case code = "Code"
        var id: Self { self }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $tab.animation(.snappy)) {
                ForEach(DetailTab.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Group {
                switch tab {
                case .problem:
                    ScrollView { problemTab.padding(16) }
                case .solution:
                    ScrollView { solutionTab.padding(16) }
                case .code:
                    codeTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(problem.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    store.toggleStar(problem)
                } label: {
                    Image(systemName: store.isStarred(problem) ? "star.fill" : "star")
                        .foregroundStyle(store.isStarred(problem) ? .yellow : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                Link(destination: problem.leetCodeURL) {
                    Image(systemName: "arrow.up.right.square")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if tab != .code { solveBar }
        }
        .sensoryFeedback(.success, trigger: store.isSolved(problem)) { old, new in !old && new }
        .fullScreenCover(isPresented: $showWalkthrough) {
            if let walkthrough = Walkthroughs.make(for: problem) {
                WalkthroughView(problem: problem, walkthrough: walkthrough)
            }
        }
    }

    // MARK: Problem tab

    private var problemTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("#\(problem.number)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)
                    DifficultyPill(difficulty: problem.difficulty)
                    TopicChip(topic: problem.topic)
                }
                Text(problem.title)
                    .font(.title2.weight(.bold))
            }

            MarkdownText(problem.description)
                .font(.body)
                .lineSpacing(4)

            ForEach(Array(problem.examples.enumerated()), id: \.offset) { index, example in
                ExampleCard(index: index + 1, example: example)
            }

            if !problem.constraints.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Constraints", icon: "ruler")
                    ForEach(problem.constraints, id: \.self) { constraint in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Circle().fill(Theme.accent).frame(width: 5, height: 5)
                            Text(constraint)
                                .font(.callout.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .card()
            }

            hintsSection
            notesSection
            relatedSection
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionHeader("My notes", icon: "note.text")
                if noteFocused {
                    Button("Save") { noteFocused = false }
                        .font(.subheadline.weight(.semibold))
                }
            }
            TextField("Write down the trick, edge cases, or where you got stuck…", text: $noteDraft, axis: .vertical)
                .lineLimit(3...12)
                .font(.subheadline)
                .focused($noteFocused)
                .padding(12)
                .background(Theme.elevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .card()
        .onAppear { noteDraft = store.note(for: problem) }
        .onChange(of: noteFocused) { _, focused in
            if !focused { store.saveNote(noteDraft, for: problem) }
        }
        .onDisappear { store.saveNote(noteDraft, for: problem) }
    }

    private var relatedSection: some View {
        let related = ProblemBank.problems(for: problem.topic).filter { $0 != problem }.prefix(3)
        return Group {
            if !related.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader("More \(problem.topic.shortName)", icon: "square.stack.3d.up")
                        .padding(.bottom, 6)
                    ForEach(Array(related)) { other in
                        NavigationLink(value: other) {
                            ProblemRow(problem: other)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .card()
            }
        }
    }

    private var hintsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Hints", icon: "lightbulb")
            ForEach(0..<hintsShown, id: \.self) { index in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(width: 22, height: 22)
                        .background(Color.yellow, in: Circle())
                    MarkdownText(problem.hints[index])
                        .font(.subheadline)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            if hintsShown < problem.hints.count {
                Button {
                    withAnimation(.spring(duration: 0.4)) { hintsShown += 1 }
                } label: {
                    Label("Reveal hint \(hintsShown + 1) of \(problem.hints.count)", systemImage: "lightbulb.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.stroke, style: StrokeStyle(lineWidth: 1, dash: [5])))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.yellow)
            }
        }
    }

    // MARK: Solution tab

    private var isSolutionLocked: Bool { lockSolutions && !solutionRevealed && !store.isSolved(problem) }

    private var solutionTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let insight = problem.insight {
                InsightCard(text: insight)
            }

            if Walkthroughs.available.contains(problem.id) {
                Button {
                    showWalkthrough = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Visual walkthrough")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Watch the algorithm run step by step on an example")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .card(padding: 14)
                }
                .buttonStyle(PressableStyle())
            }

            HStack(spacing: 12) {
                ComplexityTile(icon: "clock.fill", title: "Time", value: problem.time, color: Theme.accent)
                ComplexityTile(icon: "memorychip.fill", title: "Space", value: problem.space, color: Theme.accent2)
            }

            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Approach", icon: "point.topleft.down.to.point.bottomright.curvepath")
                ForEach(Array(problem.approach.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Theme.brandGradient, in: Circle())
                        MarkdownText(step)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .card()

            SectionHeader("Python solution", icon: "chevron.left.forwardslash.chevron.right")
            CodeBlockView(code: problem.solution)
        }
        .blur(radius: isSolutionLocked ? 12 : 0)
        .allowsHitTesting(!isSolutionLocked)
        .overlay(alignment: .top) {
            if isSolutionLocked {
                VStack(spacing: 14) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.brandGradient)
                    Text("Give it a try first")
                        .font(.title3.weight(.bold))
                    Text("Working through the problem yourself is what makes a pattern stick. Use the hints, then reveal when you're ready.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button {
                        withAnimation(.spring(duration: 0.5)) { solutionRevealed = true }
                    } label: {
                        Text("Reveal Solution")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Theme.brandGradient, in: Capsule())
                    }
                    Button("Try in the editor") {
                        withAnimation(.snappy) { tab = .code }
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.top, 40)
                .padding(.horizontal, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    // MARK: Code tab

    private var codeBinding: Binding<String> {
        Binding(
            get: { store.draft(for: problem) },
            set: { store.saveDraft($0, for: problem) }
        )
    }

    private var codeTab: some View {
        VStack(spacing: 0) {
            EditorHeader(fileName: "main.py") {
                HStack(spacing: 16) {
                    Button {
                        confirmReset = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    Button {
                        showSolutionSheet = true
                    } label: {
                        Label("Solution", systemImage: "eye")
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    Button {
                        withAnimation(.spring) { store.toggleSolved(problem) }
                    } label: {
                        Image(systemName: store.isSolved(problem) ? "checkmark.seal.fill" : "checkmark.seal")
                            .foregroundStyle(store.isSolved(problem) ? Theme.easy : CodeTheme.plain)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .foregroundStyle(CodeTheme.plain.opacity(0.85))
            }
            CodeEditor(text: codeBinding, fontSize: fontSize, autoPair: autoPair)
        }
        .background(CodeTheme.background.ignoresSafeArea(edges: .bottom))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16, style: .continuous))
        .ignoresSafeArea(.container, edges: .bottom)
        .confirmationDialog("Reset your code to the starter template?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset Code", role: .destructive) { store.resetDraft(for: problem) }
        }
        .sheet(isPresented: $showSolutionSheet) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ComplexityTile(icon: "clock.fill", title: "Time", value: problem.time, color: Theme.accent)
                            ComplexityTile(icon: "memorychip.fill", title: "Space", value: problem.space, color: Theme.accent2)
                        }
                        CodeBlockView(code: problem.solution)
                    }
                    .padding(16)
                }
                .background(Theme.background.ignoresSafeArea())
                .navigationTitle("Solution")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showSolutionSheet = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Solve bar

    private var solveBar: some View {
        let solved = store.isSolved(problem)
        return HStack(spacing: 12) {
            Button {
                withAnimation(.spring(duration: 0.4)) { store.toggleSolved(problem) }
            } label: {
                Label(solved ? "Solved" : "Mark as Solved", systemImage: solved ? "checkmark.seal.fill" : "checkmark.circle")
                    .font(.headline)
                    .symbolEffect(.bounce, value: solved)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(solved ? Theme.easy : .white)
                    .background(
                        solved ? AnyShapeStyle(Theme.easy.opacity(0.15)) : AnyShapeStyle(Theme.brandGradient),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .buttonStyle(PressableStyle())

            Button {
                withAnimation(.snappy) { tab = .code }
            } label: {
                Image(systemName: "keyboard")
                    .font(.headline)
                    .frame(width: 54, height: 52)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.stroke, lineWidth: 1))
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Open code editor")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.bar)
    }
}

// MARK: - Pieces

private struct ExampleCard: View {
    let index: Int
    let example: Example

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Example \(index)")
                .font(.subheadline.weight(.bold))
            VStack(alignment: .leading, spacing: 8) {
                labeled("Input", example.input)
                labeled("Output", example.output)
                if let explanation = example.explanation {
                    labeled("Explanation", explanation, mono: false)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.elevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12, style: .continuous)
                    .fill(Theme.accent)
                    .frame(width: 3)
            }
        }
    }

    private func labeled(_ label: String, _ value: String, mono: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text(value)
                .font(mono ? .callout.monospaced() : .callout)
                .textSelection(.enabled)
        }
    }
}

struct ComplexityTile: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.bold).monospaced())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 0)
        }
        .card(padding: 12)
    }
}
