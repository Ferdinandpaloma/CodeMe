import SwiftUI
import UIKit

// MARK: - Read-only highlighted code block

struct CodeBlockView: View {
    let code: String
    var fileName = "solution.py"
    @State private var copied = false

    private let codeFont = Font.system(size: 13, design: .monospaced)

    var body: some View {
        let lines = PythonHighlighter.highlightedLines(code)
        VStack(alignment: .leading, spacing: 0) {
            EditorHeader(fileName: fileName) {
                Button {
                    UIPasteboard.general.string = code
                    withAnimation(.snappy) { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation(.snappy) { copied = false }
                    }
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption.weight(.semibold))
                        .contentTransition(.symbolEffect(.replace))
                }
                .foregroundStyle(copied ? Theme.easy : CodeTheme.plain.opacity(0.75))
                .sensoryFeedback(.success, trigger: copied) { _, new in new }
            }

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(lines.indices, id: \.self) { index in
                        Text("\(index + 1)")
                    }
                }
                .font(codeFont)
                .foregroundStyle(CodeTheme.lineNumber)
                .padding(.leading, 12)
                .padding(.trailing, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(lines.indices, id: \.self) { index in
                            Text(lines[index]).fixedSize()
                        }
                    }
                    .font(codeFont)
                    .padding(.trailing, 16)
                }
            }
            .padding(.vertical, 14)
        }
        .background(CodeTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(CodeTheme.border, lineWidth: 1))
        .environment(\.colorScheme, .dark)
    }
}

/// macOS-style window header used above code.
struct EditorHeader<Trailing: View>: View {
    let fileName: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 6) {
            ForEach([0xFF5F57, 0xFEBC2E, 0x28C840] as [UInt32], id: \.self) { hex in
                Circle().fill(Color(hex: hex)).frame(width: 10, height: 10)
            }
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(hex: 0xFFCB6B))
                .padding(.leading, 8)
            Text(fileName)
                .font(.caption.monospaced())
                .foregroundStyle(CodeTheme.plain.opacity(0.7))
            Spacer()
            trailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(CodeTheme.header)
    }
}

// MARK: - Editable Python editor

struct CodeEditor: UIViewRepresentable {
    @Binding var text: String

    static let font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = CodeTheme.uiBackground
        textView.font = Self.font
        textView.textColor = CodeTheme.uiPlain
        textView.tintColor = UIColor(hex: 0x22D3EE)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.spellCheckingType = .no
        textView.keyboardType = .asciiCapable
        textView.keyboardAppearance = .dark
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .interactive
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 10, bottom: 48, right: 10)
        textView.delegate = context.coordinator
        textView.inputAccessoryView = context.coordinator.makeAccessoryBar(for: textView)
        textView.text = text
        context.coordinator.highlight(textView)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self
        if textView.text != text {
            textView.text = text
            context.coordinator.highlight(textView)
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: CodeEditor
        weak var textView: UITextView?

        init(_ parent: CodeEditor) { self.parent = parent }

        func highlight(_ textView: UITextView) {
            let selection = textView.selectedRange
            PythonHighlighter.apply(to: textView.textStorage, font: CodeEditor.font)
            textView.selectedRange = selection
            textView.typingAttributes = [.font: CodeEditor.font, .foregroundColor: CodeTheme.uiPlain]
        }

        func textViewDidChange(_ textView: UITextView) {
            highlight(textView)
            if parent.text != textView.text {
                parent.text = textView.text
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let ns = textView.text as NSString

            // Auto-indent: keep the current indentation, add a level after a colon.
            if text == "\n" {
                let lineStart = ns.lineRange(for: NSRange(location: range.location, length: 0)).location
                let line = ns.substring(with: NSRange(location: lineStart, length: range.location - lineStart))
                var indent = String(line.prefix { $0 == " " })
                if line.trimmingCharacters(in: .whitespaces).hasSuffix(":") { indent += "    " }
                replace(range, with: "\n" + indent, in: textView)
                return false
            }

            // Smart backspace: delete a whole 4-space indent level at once.
            if text.isEmpty && range.length == 1 {
                let lineStart = ns.lineRange(for: NSRange(location: range.location, length: 0)).location
                let cursor = range.location + 1
                let before = ns.substring(with: NSRange(location: lineStart, length: cursor - lineStart))
                if before.count >= 4, before.allSatisfy({ $0 == " " }), before.count % 4 == 0 {
                    replace(NSRange(location: cursor - 4, length: 4), with: "", in: textView)
                    return false
                }
            }
            return true
        }

        private func replace(_ range: NSRange, with string: String, in textView: UITextView) {
            guard let start = textView.position(from: textView.beginningOfDocument, offset: range.location),
                  let end = textView.position(from: start, offset: range.length),
                  let textRange = textView.textRange(from: start, to: end) else { return }
            textView.replace(textRange, withText: string)
            textViewDidChange(textView)
        }

        func makeAccessoryBar(for textView: UITextView) -> UIView {
            self.textView = textView
            let bar = UIInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 48), inputViewStyle: .keyboard)
            bar.overrideUserInterfaceStyle = .dark
            bar.allowsSelfSizing = true

            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 6
            stack.translatesAutoresizingMaskIntoConstraints = false

            let keys = ["⇥", "(", ")", "[", "]", "{", "}", ":", "=", "_", "\"", "'", ".", ",", "#", "+", "-", "*", "/", "<", ">", "!"]
            for key in keys {
                var config = UIButton.Configuration.filled()
                config.title = key
                config.baseBackgroundColor = UIColor(white: 1, alpha: 0.12)
                config.baseForegroundColor = .white
                config.cornerStyle = .medium
                config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                    var attributes = attributes
                    attributes.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
                    return attributes
                }
                let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
                    UIDevice.current.playInputClick()
                    self?.textView?.insertText(key == "⇥" ? "    " : key)
                })
                stack.addArrangedSubview(button)
            }

            let scroll = UIScrollView()
            scroll.showsHorizontalScrollIndicator = false
            scroll.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(stack)

            var doneConfig = UIButton.Configuration.plain()
            doneConfig.image = UIImage(systemName: "keyboard.chevron.compact.down")
            doneConfig.baseForegroundColor = .white
            let done = UIButton(configuration: doneConfig, primaryAction: UIAction { [weak self] _ in
                self?.textView?.resignFirstResponder()
            })
            done.translatesAutoresizingMaskIntoConstraints = false

            bar.addSubview(scroll)
            bar.addSubview(done)

            NSLayoutConstraint.activate([
                scroll.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
                scroll.topAnchor.constraint(equalTo: bar.topAnchor),
                scroll.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
                scroll.trailingAnchor.constraint(equalTo: done.leadingAnchor),

                done.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -4),
                done.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
                done.widthAnchor.constraint(equalToConstant: 44),

                stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 8),
                stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -8),
                stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 6),
                stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -6),
                stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor, constant: -12),
            ])
            return bar
        }
    }
}
