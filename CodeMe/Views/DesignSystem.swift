import SwiftUI
import UIKit

// MARK: - OKLCH colour space
//
// Every brand, semantic and topic colour is defined in OKLCH (perceptual lightness,
// chroma, hue). Equal steps in L look equally bright regardless of hue, so palettes
// stay balanced, and gradients interpolated in OKLCH never go muddy or grey in the middle.
// Colours are rendered in Display P3 with chroma reduced only when out of gamut.

struct OKLCH: Hashable {
    /// Perceptual lightness, 0...1
    var l: Double
    /// Chroma, roughly 0...0.37
    var c: Double
    /// Hue angle in degrees
    var h: Double
    var alpha: Double = 1

    init(_ l: Double, _ c: Double, _ h: Double, alpha: Double = 1) {
        self.l = l
        self.c = c
        self.h = h
        self.alpha = alpha
    }

    // MARK: Adjustments

    func adjusting(l dl: Double = 0, c dc: Double = 0, h dh: Double = 0) -> OKLCH {
        OKLCH(min(max(l + dl, 0), 1), max(c + dc, 0), h + dh, alpha: alpha)
    }

    func opacity(_ value: Double) -> OKLCH {
        var copy = self
        copy.alpha = value
        return copy
    }

    /// Interpolates along the shorter hue arc. Near-grey endpoints borrow the other hue
    /// so the blend doesn't swing through unrelated colours.
    func mix(_ other: OKLCH, _ t: Double) -> OKLCH {
        var h1 = h, h2 = other.h
        if c < 0.02 { h1 = h2 }
        if other.c < 0.02 { h2 = h1 }
        var delta = (h2 - h1).truncatingRemainder(dividingBy: 360)
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return OKLCH(
            l + (other.l - l) * t,
            c + (other.c - c) * t,
            h1 + delta * t,
            alpha: alpha + (other.alpha - alpha) * t
        )
    }

    // MARK: Conversion

    /// Linear sRGB for this colour (may fall outside 0...1).
    private static func linearSRGB(l: Double, a: Double, b: Double) -> (Double, Double, Double) {
        let l_ = l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = l - 0.0894841775 * a - 1.2914855480 * b
        let L = l_ * l_ * l_, M = m_ * m_ * m_, S = s_ * s_ * s_
        return (
            +4.0767416621 * L - 3.3077115913 * M + 0.2309699292 * S,
            -1.2684380046 * L + 2.6097574011 * M - 0.3413193965 * S,
            -0.0041960863 * L - 0.7034186147 * M + 1.7076147010 * S
        )
    }

    private static func linearP3(l: Double, c: Double, h: Double) -> (Double, Double, Double) {
        let rad = h * .pi / 180
        let (r, g, b) = linearSRGB(l: l, a: c * cos(rad), b: c * sin(rad))
        return (
            0.8224621 * r + 0.1775380 * g,
            0.0331941 * r + 0.9668058 * g,
            0.0170827 * r + 0.0723974 * g + 0.9105199 * b
        )
    }

    private static func inGamut(_ rgb: (Double, Double, Double)) -> Bool {
        let e = 0.0005
        return rgb.0 >= -e && rgb.0 <= 1 + e && rgb.1 >= -e && rgb.1 <= 1 + e && rgb.2 >= -e && rgb.2 <= 1 + e
    }

    private static func encode(_ x: Double) -> Double {
        let v = min(max(x, 0), 1)
        return v <= 0.0031308 ? 12.92 * v : 1.055 * pow(v, 1 / 2.4) - 0.055
    }

    /// Gamma-encoded Display P3 components, chroma-reduced into gamut (hue and lightness kept).
    var displayP3: (r: Double, g: Double, b: Double) {
        var rgb = Self.linearP3(l: l, c: c, h: h)
        if !Self.inGamut(rgb) {
            var lo = 0.0, hi = c
            for _ in 0..<18 {
                let mid = (lo + hi) / 2
                if Self.inGamut(Self.linearP3(l: l, c: mid, h: h)) { lo = mid } else { hi = mid }
            }
            rgb = Self.linearP3(l: l, c: lo, h: h)
        }
        return (Self.encode(rgb.0), Self.encode(rgb.1), Self.encode(rgb.2))
    }

    var uiColor: UIColor {
        let p3 = displayP3
        return UIColor(displayP3Red: p3.r, green: p3.g, blue: p3.b, alpha: alpha)
    }

    var color: Color { Color(uiColor: uiColor) }

    /// Reads any (static) colour back into OKLCH.
    init(_ color: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        func linear(_ v: CGFloat) -> Double {
            let x = Double(abs(v))
            let lin = x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4)
            return v < 0 ? -lin : lin
        }
        let (R, G, B) = (linear(r), linear(g), linear(b))
        let lm = cbrt(0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B)
        let mm = cbrt(0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B)
        let sm = cbrt(0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B)
        let L = 0.2104542553 * lm + 0.7936177850 * mm - 0.0040720468 * sm
        let A = 1.9779984951 * lm - 2.4285922050 * mm + 0.4505937099 * sm
        let Bb = 0.0259040371 * lm + 0.7827717662 * mm - 0.8086757660 * sm
        var hue = atan2(Bb, A) * 180 / .pi
        if hue < 0 { hue += 360 }
        self.init(L, (A * A + Bb * Bb).squareRoot(), hue, alpha: Double(a))
    }
}

extension Color {
    init(oklch l: Double, _ c: Double, _ h: Double, opacity: Double = 1) {
        self = OKLCH(l, c, h, alpha: opacity).color
    }

    /// Appearance-aware colour defined in OKLCH for light and dark mode.
    init(light: OKLCH, dark: OKLCH) {
        let lightColor = light.uiColor, darkColor = dark.uiColor
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? darkColor : lightColor })
    }

    var oklch: OKLCH { OKLCH(UIColor(self)) }

    /// A two-tone gradient built in OKLCH: a lighter, slightly cooler top-leading tint
    /// sliding into a deeper, warmer bottom-trailing shade. Replaces `Color.gradient`.
    var oklchGradient: LinearGradient {
        let base = oklch
        return OKGradient.linear([
            base.adjusting(l: 0.07, c: -0.01, h: -14),
            base,
            base.adjusting(l: -0.06, c: 0.015, h: 12),
        ])
    }
}

enum OKGradient {
    /// Samples a multi-stop OKLCH ramp into evenly spaced sRGB stops, so the system's
    /// linear interpolation between neighbours stays visually faithful.
    static func colors(_ stops: [OKLCH], samples: Int = 14) -> [Color] {
        guard stops.count > 1 else { return stops.map(\.color) }
        return (0...samples).map { i in
            let position = Double(i) / Double(samples) * Double(stops.count - 1)
            let index = min(Int(position), stops.count - 2)
            return stops[index].mix(stops[index + 1], position - Double(index)).color
        }
    }

    static func linear(_ stops: [OKLCH], start: UnitPoint = .topLeading, end: UnitPoint = .bottomTrailing) -> LinearGradient {
        LinearGradient(colors: colors(stops), startPoint: start, endPoint: end)
    }

    static func angular(_ stops: [OKLCH]) -> AngularGradient {
        AngularGradient(colors: colors(stops + [stops[0]], samples: 24), center: .center)
    }
}

// MARK: - Palette (OKLCH)

/// Named hues with matched lightness and chroma so no colour shouts louder than another.
enum Palette {
    static let violet = OKLCH(0.60, 0.22, 288)
    static let indigo = OKLCH(0.58, 0.19, 274)
    static let blue = OKLCH(0.64, 0.18, 255)
    static let sky = OKLCH(0.70, 0.15, 232)
    static let cyan = OKLCH(0.79, 0.13, 210)
    static let teal = OKLCH(0.72, 0.13, 182)
    static let green = OKLCH(0.73, 0.19, 148)
    static let lime = OKLCH(0.80, 0.19, 128)
    static let yellow = OKLCH(0.84, 0.16, 92)
    static let amber = OKLCH(0.78, 0.16, 72)
    static let orange = OKLCH(0.71, 0.18, 48)
    static let red = OKLCH(0.64, 0.22, 26)
    static let rose = OKLCH(0.65, 0.22, 12)
    static let pink = OKLCH(0.71, 0.18, 350)

    /// Topic colours: golden-angle hue steps so neighbouring roadmap nodes always contrast,
    /// with lightness lifted around yellow (which looks muddy at low L).
    static func topic(_ index: Int) -> OKLCH {
        let hue = (288 + Double(index) * 137.508).truncatingRemainder(dividingBy: 360)
        let yellowness = max(0, cos((hue - 100) * .pi / 180))
        return OKLCH(0.66 + 0.13 * yellowness * yellowness, 0.17, hue)
    }
}

// MARK: - Concentric radii
//
// A rounded shape nested inside another at inset `p` should use radius `outer - p`,
// so both curves share a centre. We fix the control radius and derive containers from it.

enum Radius {
    /// Buttons, icon tiles and controls that sit inside cards.
    static let control: CGFloat = 12
    /// Small tags and code highlights.
    static let small: CGFloat = 8

    /// Outer radius for a container whose content is inset by `padding`.
    static func outer(inner: CGFloat = control, padding: CGFloat) -> CGFloat { inner + padding }

    /// Inner radius for content inset by `padding` inside a container of radius `outer`.
    static func inner(outer: CGFloat, padding: CGFloat) -> CGFloat { max(outer - padding, 4) }
}

extension Shape where Self == RoundedRectangle {
    static func rounded(_ radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}

// MARK: - Surfaces: alpha borders + dark-mode depth
//
// Borders are translucent (black in light mode, white in dark) so they pick up whatever
// is behind them instead of drawing a flat grey line. In dark mode, elevation is shown by
// lighter surfaces and a lit top edge rather than shadows, which disappear on black.

struct Surface<S: InsettableShape>: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    let shape: S
    var fill: Color = Theme.card
    var elevation: Double = 1

    func body(content: Content) -> some View {
        let dark = scheme == .dark
        content
            .background {
                shape.fill(fill)
                    .overlay {
                        if dark {
                            // Light falls from above: faint sheen on the top half.
                            shape.fill(LinearGradient(colors: [.white.opacity(0.035 * elevation), .clear],
                                                      startPoint: .top, endPoint: .center))
                        }
                    }
                    .shadow(color: .black.opacity(dark ? 0 : 0.045 * elevation), radius: 10 * elevation, y: 4 * elevation)
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: dark
                            ? [.white.opacity(0.13), .white.opacity(0.05)]
                            : [.black.opacity(0.05), .black.opacity(0.09)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: dark ? 0.75 : 0.5
                )
            }
    }
}

extension View {
    func surface<S: InsettableShape>(_ shape: S, fill: Color = Theme.card, elevation: Double = 1) -> some View {
        modifier(Surface(shape: shape, fill: fill, elevation: elevation))
    }

    func surface(radius: CGFloat, fill: Color = Theme.card, elevation: Double = 1) -> some View {
        modifier(Surface(shape: RoundedRectangle(cornerRadius: radius, style: .continuous), fill: fill, elevation: elevation))
    }
}

// MARK: - Multi-blend backgrounds

/// Hero backdrop composed with several blend modes: an OKLCH base gradient, two light
/// blooms (`.screen` and `.plusLighter`), a soft-light sheen and a multiply vignette.
struct AuroraBackground: View {
    let stops: [OKLCH]
    var glow: OKLCH? = nil

    var body: some View {
        let first = stops.first ?? Palette.violet
        let last = stops.last ?? Palette.cyan
        GeometryReader { geo in
            let size = max(geo.size.width, geo.size.height)
            ZStack {
                OKGradient.linear(stops)
                RadialGradient(colors: [(glow ?? last.adjusting(l: 0.08)).opacity(0.5).color, .clear],
                               center: .topTrailing, startRadius: 0, endRadius: size * 0.6)
                    .blendMode(.screen)
                RadialGradient(colors: [first.adjusting(l: 0.1, h: -20).opacity(0.3).color, .clear],
                               center: .bottomLeading, startRadius: 0, endRadius: size * 0.55)
                    .blendMode(.plusLighter)
                LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .center)
                    .blendMode(.softLight)
                LinearGradient(colors: [.clear, .black.opacity(0.3)], startPoint: .center, endPoint: .bottom)
                    .blendMode(.multiply)
            }
            .compositingGroup()
        }
    }
}

extension View {
    /// White text that blends `.plusLighter` with the colourful background, so secondary
    /// copy reads as tinted light instead of flat grey.
    func vibrant(_ opacity: Double = 0.75) -> some View {
        foregroundStyle(.white.opacity(opacity)).blendMode(.plusLighter)
    }
}

// MARK: - Masked edges

private struct ScrollFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

/// Horizontal scroll view whose edges fade out only where there's more content to scroll to.
struct FadingScrollView<Content: View>: View {
    var fade: CGFloat = 24
    @ViewBuilder var content: Content

    @State private var viewport: CGFloat = 0
    @State private var fadeLeading = false
    @State private var fadeTrailing = false
    @State private var space = UUID()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            content.background(
                GeometryReader { geo in
                    Color.clear.preference(key: ScrollFrameKey.self, value: geo.frame(in: .named(space)))
                }
            )
        }
        .coordinateSpace(name: space)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { viewport = geo.size.width }
                    .onChange(of: geo.size.width) { _, width in viewport = width }
            }
        )
        .onPreferenceChange(ScrollFrameKey.self) { frame in
            let leading = frame.minX < -1
            let trailing = frame.maxX > viewport + 1
            if leading != fadeLeading || trailing != fadeTrailing {
                withAnimation(.easeOut(duration: 0.2)) {
                    fadeLeading = leading
                    fadeTrailing = trailing
                }
            }
        }
        .mask {
            HStack(spacing: 0) {
                LinearGradient(colors: [.black.opacity(fadeLeading ? 0 : 1), .black], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fade)
                Color.black
                LinearGradient(colors: [.black, .black.opacity(fadeTrailing ? 0 : 1)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fade)
            }
        }
    }
}

// MARK: - Blurred icon swaps

/// An SF Symbol that blurs out and back in when its name changes, instead of hard-cutting.
struct SwapIcon: View {
    let name: String

    init(_ name: String) { self.name = name }

    var body: some View {
        ZStack {
            Image(systemName: name)
                .id(name)
                .transition(.asymmetric(
                    insertion: AnyTransition(.blurReplace).combined(with: .scale(scale: 0.6)),
                    removal: AnyTransition(.blurReplace).combined(with: .scale(scale: 1.3))
                ))
        }
        .animation(.spring(duration: 0.4, bounce: 0.3), value: name)
    }
}

// MARK: - Dynamic viewport

extension View {
    /// Sizes a view as a fraction of the visible scroll viewport (like CSS `dvw`), clamped
    /// so it reads well on everything from an iPhone SE to a Pro Max.
    func viewportWidth(_ fraction: CGFloat, min lower: CGFloat, max upper: CGFloat) -> some View {
        containerRelativeFrame(.horizontal) { length, _ in
            Swift.min(Swift.max(length * fraction, lower), upper)
        }
    }
}

/// Picks a column count from the width actually available, so grids reflow with the
/// viewport and with Dynamic Type instead of hard-coding a count.
struct AdaptiveColumns {
    static func count(width: CGFloat, minimum: CGFloat, maxCount: Int) -> Int {
        Swift.max(1, Swift.min(maxCount, Int(width / minimum)))
    }
}
