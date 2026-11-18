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
    // Brand & semantic colours, all in OKLCH (see DesignSystem.swift).
    static let accent = Palette.violet.color
    static let accent2 = Palette.cyan.color
    static let brandStops = [Palette.violet, Palette.blue, Palette.cyan]
    static let brandGradient = OKGradient.linear(brandStops)
    /// Deeper ramp for hero surfaces that carry white text (keeps contrast at the cyan end).
    static let heroStops = [Palette.violet, Palette.blue.adjusting(l: -0.04), Palette.sky.adjusting(l: -0.08, c: 0.01)]
    static let easy = Palette.green.color
    static let medium = Palette.amber.color
    static let hard = Palette.red.color
    /// Yellow is too light for text on white, so light mode uses a deeper amber at the same hue.
    static let insight = Color(light: OKLCH(0.60, 0.13, 80), dark: Palette.yellow)

    // Neutrals carry a whisper of the brand hue. In dark mode each elevation step is
    // lighter (depth through luminance), in light mode surfaces sit on a cool grey canvas.
    static let background = Color(light: OKLCH(0.972, 0.006, 280), dark: OKLCH(0.135, 0.012, 280))
    static let card = Color(light: OKLCH(1.0, 0, 0), dark: OKLCH(0.19, 0.015, 280))
    static let elevated = Color(light: OKLCH(0.955, 0.008, 280), dark: OKLCH(0.245, 0.018, 280))
    /// Translucent hairline: black in light mode, white in dark, so it tints with what's behind.
    static let stroke = Color(light: OKLCH(0, 0, 0, alpha: 0.09), dark: OKLCH(1, 0, 0, alpha: 0.10))
}

// MARK: - Card

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Concentric: controls inside use Radius.control, so the card is control + padding.
            .surface(radius: Radius.outer(padding: padding))
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
            .background(topic.color.oklchGradient, in: .rounded(size * 0.3))
            .overlay(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous).strokeBorder(.white.opacity(0.18), lineWidth: 0.5).blendMode(.plusLighter))
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
                    .fill(color.oklchGradient)
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
        OKGradient.angular(Theme.brandStops)
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
            SwapIcon(solved ? "checkmark.circle.fill" : "circle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(solved ? Theme.easy : Color.secondary.opacity(0.45))
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
                Image(systemName: "star.fill").font(.caption.weight(.semibold)).foregroundStyle(Palette.yellow.color)
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
                .background(isOn ? AnyShapeStyle(color.oklchGradient) : AnyShapeStyle(Theme.card), in: Capsule())
                .overlay(Capsule().strokeBorder(isOn ? AnyShapeStyle(.white.opacity(0.2)) : AnyShapeStyle(Theme.stroke), lineWidth: 0.75))
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isOn)
    }
}
