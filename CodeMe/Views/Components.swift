import SwiftUI

// MARK: - Colors & theme

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Color {
    init(hex: UInt32) { self.init(uiColor: UIColor(hex: hex)) }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

enum Theme {
    static let accent = Color(hex: 0x7C5CFF)
    static let accent2 = Color(hex: 0x22D3EE)
    static let brandGradient = LinearGradient(colors: [accent, Color(hex: 0x5B8CFF), accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let background = Color(light: 0xF3F4F9, dark: 0x0A0B10)
    static let card = Color(light: 0xFFFFFF, dark: 0x14161F)
    static let elevated = Color(light: 0xEEF0F6, dark: 0x1C1F2B)
    static let stroke = Color(light: 0xE4E6EE, dark: 0x232736)
    static let easy = Color(hex: 0x22C55E)
    static let medium = Color(hex: 0xF59E0B)
    static let hard = Color(hex: 0xEF4444)
}

// MARK: - Card

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Theme.stroke, lineWidth: 1))
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View { modifier(CardModifier(padding: padding)) }
}

// MARK: - Small components

struct DifficultyPill: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(difficulty.color)
            .background(difficulty.color.opacity(0.14), in: Capsule())
    }
}

struct TopicChip: View {
    let topic: Topic

    var body: some View {
        Label(topic.shortName, systemImage: topic.icon)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(topic.color)
            .background(topic.color.opacity(0.14), in: Capsule())
    }
}

struct TopicIcon: View {
    let topic: Topic
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: topic.icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(topic.color.gradient, in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

struct ProgressBar: View {
    let progress: Double
    var color: Color = Theme.accent
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.08))
                Capsule()
                    .fill(color.gradient)
                    .frame(width: max(progress > 0 ? height : 0, geo.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: height)
        .animation(.spring(duration: 0.5), value: progress)
    }
}

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 10
    var track: Color = Color.primary.opacity(0.08)
    var fill: AnyShapeStyle = AnyShapeStyle(
        AngularGradient(colors: [Theme.accent, Theme.accent2, Theme.accent], center: .center)
    )

    var body: some View {
        ZStack {
            Circle().stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(fill, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .animation(.spring(duration: 0.7), value: progress)
    }
}

struct SectionHeader: View {
    let title: String
    var icon: String? = nil

    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon).foregroundStyle(Theme.accent)
            }
            Text(title)
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Renders inline markdown (`code`, **bold**, *italic*) while keeping line breaks.
struct MarkdownText: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(Self.parse(text))
    }

    static func parse(_ text: String) -> AttributedString {
        (try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(text)
    }
}

struct ProblemRow: View {
    @Environment(ProgressStore.self) private var store
    let problem: Problem
    var showTopic = true

    var body: some View {
        let solved = store.isSolved(problem)
        HStack(spacing: 12) {
            Image(systemName: solved ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(solved ? Theme.easy : Color.secondary.opacity(0.45))
                .contentTransition(.symbolEffect(.replace))
            VStack(alignment: .leading, spacing: 3) {
                Text(problem.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Text(showTopic ? "#\(problem.number) · \(problem.topic.shortName)" : "#\(problem.number)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if store.isStarred(problem) {
                Image(systemName: "star.fill").font(.caption).foregroundStyle(.yellow)
            }
            DifficultyPill(difficulty: problem.difficulty)
        }
        .contentShape(Rectangle())
    }
}

struct FilterChip: View {
    let title: String
    let isOn: Bool
    var color: Color = Theme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isOn ? .white : .primary)
                .background(isOn ? AnyShapeStyle(color.gradient) : AnyShapeStyle(Theme.card), in: Capsule())
                .overlay(Capsule().strokeBorder(isOn ? .clear : Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isOn)
    }
}
