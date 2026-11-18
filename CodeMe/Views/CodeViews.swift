import SwiftUI
import UIKit

// MARK: - Read-only highlighted code block

struct CodeBlockView: View {
    let code: String
    var fileName = "solution.py"
    var highlightedLine: Int? = nil
    @State private var copied = false
    @AppStorage(SettingsKey.editorFontSize) private var fontSize = SettingsKey.defaultFontSize

    private var codeFont: Font { .system(size: max(10, fontSize - 1), design: .monospaced) }

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
                            .foregroundStyle(index + 1 == highlightedLine ? Theme.accent2 : CodeTheme.lineNumber)
                            .fontWeight(index + 1 == highlightedLine ? .bold : .regular)
                    }
                }
                .font(codeFont)
                .padding(.leading, 12)
                .padding(.trailing, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(lines.indices, id: \.self) { index in
                            Text(lines[index])
                                .fixedSize()
                                .padding(.horizontal, 4)
                                .background(
                                    index + 1 == highlightedLine ? Theme.accent.opacity(0.35) : .clear,
                                    in: RoundedRectangle(cornerRadius: 4, style: .continuous)
                                )
                                .id(index + 1)
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
    var fontSize: Double = SettingsKey.defaultFontSize
    var autoPair = true

    var font: UIFont { .monospacedSystemFont(ofSize: fontSize, weight: .regular) }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = CodeTheme.uiBackground
        textView.font = font
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
        let fontChanged = context.coordinator.parent.fontSize != fontSize
        context.coordinator.parent = self
        if textView.text != text || fontChanged {
            if textView.text != text { textView.text = text }
            context.coordinator.highlight(textView)
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: CodeEditor
        weak var textView: UITextView?

        init(_ parent: CodeEditor) { self.parent = parent }

        func highlight(_ textView: UITextView) {
            let selection = textView.selectedRange
            let font = parent.font
            PythonHighlighter.apply(to: textView.textStorage, font: font)
            textView.selectedRange = selection
            textView.typingAttributes = [.font: font, .foregroundColor: CodeTheme.uiPlain]
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

            if parent.autoPair, range.length == 0, let handled = autoPair(text, at: range.location, in: textView) {
                return handled
            }

            // Delete an empty bracket pair together: "(|)" -> "|".
            if parent.autoPair, text.isEmpty, range.length == 1, range.location + 2 <= ns.length {
                let pair = ns.substring(with: NSRange(location: range.location, length: 2))
                if Self.pairs.contains(where: { "\($0.key)\($0.value)" == pair }) {
                    replace(NSRange(location: range.location, length: 2), with: "", in: textView)
                    return false
                }
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

        static let pairs: [String: String] = ["(": ")", "[": "]", "{": "}", "\"": "\"", "'": "'"]
        private static let closers: Set<String> = [")", "]", "}", "\"", "'"]

        /// Inserts matching closers and steps over a closer that's already there.
        /// Returns nil when the keystroke should be handled normally.
        private func autoPair(_ text: String, at location: Int, in textView: UITextView) -> Bool? {
            let ns = textView.text as NSString
            let next = location < ns.length ? ns.substring(with: NSRange(location: location, length: 1)) : ""
            let prev = location > 0 ? ns.substring(with: NSRange(location: location - 1, length: 1)) : ""

            if Self.closers.contains(text), next == text {
                textView.selectedRange = NSRange(location: location + 1, length: 0)
                return false
            }
            guard let closer = Self.pairs[text] else { return nil }
            if text == "\"" || text == "'" {
                // Don't pair inside words (e.g. don't) or right before text.
                if prev.first?.isLetter == true || prev.first?.isNumber == true { return nil }
            }
            if let n = next.first, n.isLetter || n.isNumber { return nil }
            replace(NSRange(location: location, length: 0), with: text + closer, in: textView)
            textView.selectedRange = NSRange(location: location + 1, length: 0)
            return false
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
