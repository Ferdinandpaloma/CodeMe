import SwiftUI
import UIKit

enum TokenKind {
    case keyword, builtin, function, className, string, number, comment, decorator, selfRef
}

/// Editor color theme (a dark palette inspired by Material Palenight).
enum CodeTheme {
    static let background = Color(hex: 0x0F111A)
    static let header = Color(hex: 0x161925)
    static let border = Color(hex: 0x23263A)
    static let plain = Color(hex: 0xC8D3F5)
    static let lineNumber = Color(hex: 0x4B5270)
    static let uiBackground = UIColor(hex: 0x0F111A)
    static let uiPlain = UIColor(hex: 0xC8D3F5)

    static func uiColor(for kind: TokenKind) -> UIColor {
        switch kind {
        case .keyword: UIColor(hex: 0xC792EA)
        case .builtin: UIColor(hex: 0x89DDFF)
        case .function: UIColor(hex: 0x82AAFF)
        case .className: UIColor(hex: 0xFFCB6B)
        case .string: UIColor(hex: 0xC3E88D)
        case .number: UIColor(hex: 0xF78C6C)
        case .comment: UIColor(hex: 0x676E95)
        case .decorator: UIColor(hex: 0xFFCB6B)
        case .selfRef: UIColor(hex: 0xFF757F)
        }
    }

    static func color(for kind: TokenKind) -> Color { Color(uiColor: uiColor(for: kind)) }
}

/// A small regex-based tokenizer for Python source.
enum PythonHighlighter {
    private static func regex(_ pattern: String) -> NSRegularExpression {
        try! NSRegularExpression(pattern: pattern)
    }

    /// Strings and comments are matched in a single left-to-right pass so a `#` inside
    /// a string (or quotes inside a comment) are classified correctly.
    private static let stringsAndComments = regex(
        #"(\"\"\"[\s\S]*?\"\"\"|'''[\s\S]*?'''|[rRbBfFuU]{0,2}"(?:\\.|[^"\\\n])*"|[rRbBfFuU]{0,2}'(?:\\.|[^'\\\n])*'|#[^\n]*)"#
    )

    private static let keywords = [
        "False", "None", "True", "and", "as", "assert", "async", "await", "break", "class",
        "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global",
        "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise",
        "return", "try", "while", "with", "yield",
    ]

    private static let builtins = [
        "abs", "all", "any", "bool", "chr", "dict", "enumerate", "filter", "float", "int",
        "isinstance", "len", "list", "map", "max", "min", "object", "ord", "print", "range",
        "reversed", "set", "sorted", "str", "sum", "super", "tuple", "zip", "List", "Optional",
        "Dict", "Set", "Tuple", "defaultdict", "deque", "Counter", "OrderedDict", "heapq",
        "math", "bisect_left", "bisect_right", "cache", "collections",
    ]

    /// Applied in order; later rules override earlier ones.
    private static let rules: [(NSRegularExpression, TokenKind, Int)] = [
        (regex(#"\b([A-Za-z_]\w*)(?=\s*\()"#), .function, 1),
        (regex(#"\b(\#(builtins.joined(separator: "|")))\b"#), .builtin, 1),
        (regex(#"\b(self|cls)\b"#), .selfRef, 1),
        (regex(#"\b(\#(keywords.joined(separator: "|")))\b"#), .keyword, 1),
        (regex(#"\bdef\s+([A-Za-z_]\w*)"#), .function, 1),
        (regex(#"\bclass\s+([A-Za-z_]\w*)"#), .className, 1),
        (regex(#"\b\d+(?:\.\d+)?\b"#), .number, 0),
        (regex(#"@[A-Za-z_][\w.]*"#), .decorator, 0),
    ]

    static func tokens(in code: String) -> [(range: NSRange, kind: TokenKind)] {
        let ns = code as NSString
        let full = NSRange(location: 0, length: ns.length)

        var protected: [(range: NSRange, kind: TokenKind)] = []
        for match in stringsAndComments.matches(in: code, range: full) {
            let isComment = ns.character(at: match.range.location) == 35 // "#"
            protected.append((match.range, isComment ? .comment : .string))
        }

        var result: [(range: NSRange, kind: TokenKind)] = []
        for (regex, kind, group) in rules {
            for match in regex.matches(in: code, range: full) {
                let range = match.range(at: group)
                guard range.location != NSNotFound else { continue }
                if protected.contains(where: { NSIntersectionRange($0.range, range).length > 0 }) { continue }
                result.append((range, kind))
            }
        }
        return result + protected
    }

    /// Highlighted lines for SwiftUI `Text` rendering.
    static func highlightedLines(_ code: String) -> [AttributedString] {
        let toks = tokens(in: code)
        var lines = code.components(separatedBy: "\n")
        if lines.count > 1, lines.last?.isEmpty == true { lines.removeLast() }

        var location = 0
        var output: [AttributedString] = []
        for line in lines {
            let length = (line as NSString).length
            let lineRange = NSRange(location: location, length: length)
            var attributed = AttributedString(line.isEmpty ? " " : line)
            attributed.foregroundColor = CodeTheme.plain
            if !line.isEmpty {
                for token in toks {
                    let overlap = NSIntersectionRange(token.range, lineRange)
                    guard overlap.length > 0 else { continue }
                    let local = NSRange(location: overlap.location - location, length: overlap.length)
                    if let range = Range(local, in: attributed) {
                        attributed[range].foregroundColor = CodeTheme.color(for: token.kind)
                    }
                }
            }
            output.append(attributed)
            location += length + 1
        }
        return output
    }

    /// Re-colors a UITextView's storage in place.
    static func apply(to storage: NSTextStorage, font: UIFont) {
        let full = NSRange(location: 0, length: storage.length)
        storage.beginEditing()
        storage.setAttributes([.font: font, .foregroundColor: CodeTheme.uiPlain], range: full)
        for token in tokens(in: storage.string) {
            storage.addAttribute(.foregroundColor, value: CodeTheme.uiColor(for: token.kind), range: token.range)
        }
        storage.endEditing()
    }
}
