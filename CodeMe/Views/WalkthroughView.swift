import SwiftUI

/// Animated, step-by-step visualization of an algorithm running on a sample input.
struct WalkthroughView: View {
    let problem: Problem
    let walkthrough: Walkthrough
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var playing = false

    private var step: TraceStep { walkthrough.steps[index] }
    private var isLast: Bool { index == walkthrough.steps.count - 1 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text(walkthrough.input)
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ArrayStrip(step: step)

                if !step.vars.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(step.vars, id: \.name) { variable in
                                HStack(spacing: 4) {
                                    Text(variable.name).foregroundStyle(.secondary)
                                    Text("=").foregroundStyle(.tertiary)
                                    Text(variable.value)
                                        .fontWeight(.bold)
                                        .contentTransition(.numericText())
                                }
                                .font(.footnote.monospaced())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Theme.card, in: Capsule())
                                .overlay(Capsule().strokeBorder(Theme.stroke, lineWidth: 1))
                            }
                        }
                    }
                }

                ForEach(step.panels, id: \.title) { panel in
                    PanelView(panel: panel)
                }

                narration

                ScrollViewReader { proxy in
                    ScrollView {
                        CodeBlockView(code: problem.solution, fileName: "solution.py", highlightedLine: step.line)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: index) {
                        withAnimation(.snappy) { proxy.scrollTo(step.line, anchor: .center) }
                    }
                }
                .frame(minHeight: 140)

                controls
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(problem.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task(id: playing) {
                guard playing else { return }
                while playing && !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1.6))
                    guard playing, !Task.isCancelled else { return }
                    if isLast {
                        playing = false
                    } else {
                        withAnimation(.spring(duration: 0.45)) { index += 1 }
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: index)
        }
    }

    private var narration: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("STEP \(index + 1) OF \(walkthrough.steps.count)")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text("line \(step.line)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
            MarkdownText(step.note)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .id(index)
                .transition(.opacity)
        }
        .card(padding: 14)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            ProgressBar(progress: Double(index + 1) / Double(walkthrough.steps.count), color: Theme.accent, height: 4)
            HStack(spacing: 14) {
                controlButton("backward.end.fill", enabled: index > 0) {
                    playing = false
                    withAnimation(.spring(duration: 0.4)) { index = 0 }
                }
                controlButton("backward.fill", enabled: index > 0) {
                    playing = false
                    withAnimation(.spring(duration: 0.4)) { index -= 1 }
                }
                Button {
                    if isLast { index = 0 }
                    playing.toggle()
                } label: {
                    Image(systemName: playing ? "pause.fill" : (isLast ? "arrow.counterclockwise" : "play.fill"))
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(Theme.brandGradient, in: Circle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(PressableStyle())
                controlButton("forward.fill", enabled: !isLast) {
                    playing = false
                    withAnimation(.spring(duration: 0.4)) { index += 1 }
                }
                controlButton("forward.end.fill", enabled: !isLast) {
                    playing = false
                    withAnimation(.spring(duration: 0.4)) { index = walkthrough.steps.count - 1 }
                }
            }
        }
    }

    private func controlButton(_ icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 46, height: 46)
                .background(Theme.card, in: Circle())
                .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }
}

/// Array cells with sliding pointer labels underneath.
private struct ArrayStrip: View {
    let step: TraceStep
    @Namespace private var pointerSpace

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(step.cells.indices, id: \.self) { i in
                VStack(spacing: 4) {
                    Text("\(i)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(step.cells[i])
                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(fill(i), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(border(i), lineWidth: 1.5))
                        .opacity(step.dimmed.contains(i) ? 0.3 : 1)
                        .scaleEffect(step.active.contains(i) ? 1.06 : 1)
                    VStack(spacing: 2) {
                        ForEach(step.pointers.filter { $0.index == i }, id: \.label) { pointer in
                            Text(pointer.label)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(color(for: pointer.label), in: Capsule())
                                .matchedGeometryEffect(id: pointer.label, in: pointerSpace)
                        }
                    }
                    .frame(height: 36, alignment: .top)
                }
            }
        }
    }

    private func inWindow(_ i: Int) -> Bool { step.window?.contains(i) ?? false }

    private func fill(_ i: Int) -> Color {
        if step.found.contains(i) { return Theme.easy.opacity(0.3) }
        if step.active.contains(i) { return Theme.accent.opacity(0.35) }
        if inWindow(i) { return Theme.accent.opacity(0.13) }
        return Theme.card
    }

    private func border(_ i: Int) -> Color {
        if step.found.contains(i) { return Theme.easy }
        if step.active.contains(i) { return Theme.accent }
        if inWindow(i) { return Theme.accent.opacity(0.4) }
        return Theme.stroke
    }

    private func color(for label: String) -> Color {
        switch label {
        case "l", "buy", "j": Theme.accent
        case "r", "i", "day", "sell", "c": Color(hex: 0x0EA5E9)
        case "mid": Theme.medium
        default: Color(hex: 0xEC4899)
        }
    }
}

private struct PanelView: View {
    let panel: TracePanel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(panel.title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    if panel.items.isEmpty {
                        Text("empty")
                            .font(.footnote.monospaced())
                            .foregroundStyle(.tertiary)
                            .padding(.vertical, 6)
                    }
                    ForEach(Array(panel.items.enumerated()), id: \.offset) { _, item in
                        Text(item)
                            .font(.footnote.monospaced().weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Theme.accent2.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Theme.accent2.opacity(0.4), lineWidth: 1))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
