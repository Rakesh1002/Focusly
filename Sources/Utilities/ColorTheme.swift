import SwiftUI
import AppKit

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
}

extension TimeInterval {
    var clock: String {
        let seconds = Int(self)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    /// "1h 5m", "23m"; rounds up so a meeting 30s away reads as "1m", not "0m".
    var shortDuration: String {
        let minutes = Int((self / 60).rounded(.up))
        guard minutes >= 60 else { return "\(minutes)m" }
        return minutes % 60 == 0 ? "\(minutes / 60)h" : "\(minutes / 60)h \(minutes % 60)m"
    }
}

// Liquid Glass on macOS 26+, system materials before that. Views use these and never check availability themselves.
extension View {
    func glassBackground(in shape: some Shape, interactive: Bool = false, tint: Color? = nil) -> some View {
        modifier(GlassBackground(shape: shape, interactive: interactive, tint: tint))
    }
}

private struct GlassBackground<S: Shape>: ViewModifier {
    let shape: S
    let interactive: Bool
    let tint: Color?
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.glassEffect(.regular.tint(tint).interactive(interactive), in: shape)
        } else if reduceTransparency {
            content.background(Color(nsColor: .windowBackgroundColor), in: shape)
        } else {
            content.background {
                shape.fill(.regularMaterial).overlay(shape.fill(tint ?? .clear))
            }
        }
    }
}

extension NSWindow {
    /// Puts the content on Liquid Glass on macOS 26+; earlier systems keep the plain window background.
    func setGlassContent(_ content: NSView, cornerRadius: CGFloat) {
        guard #available(macOS 26, *) else {
            contentView = content
            return
        }
        let glass = NSGlassEffectView()
        glass.cornerRadius = cornerRadius
        glass.contentView = content
        isOpaque = false
        backgroundColor = .clear
        contentView = glass
    }
}

// MARK: - Immersive surfaces (tray, floating timer, break screen, onboarding)
// Graphite Liquid Glass with one signature "tide" accent (teal to sky) and a warm "dawn" for breaks.

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum Brand {
    static let tide = [Color(hex: 0x2EE6C5), Color(hex: 0x4FA8FF)]
    static let dawn = [Color(hex: 0xFFB86B), Color(hex: 0xFF7E8A)]
    static let accent = Color(hex: 0x5EEAD4)
    static let warning = Color(hex: 0xFBBF24)
    static let urgent = Color(hex: 0xFF7E8A)
    static let onAccent = Color(hex: 0x05231E)
    static let orb = [Color(hex: 0x2EE6C5), Color(hex: 0x3B9EFF), Color(hex: 0x6366F1)]
}

/// The three moods every immersive surface is tinted by.
enum Mood {
    case ready, focus, rest

    var colors: [Color] {
        switch self {
        case .ready, .focus: return Brand.tide
        case .rest: return Brand.dawn
        }
    }

    var glow: Color { colors[0] }

    /// The coloured word in "Focus: Ready".
    var word: String {
        switch self {
        case .ready: return "Ready"
        case .focus: return "On"
        case .rest: return "Break"
        }
    }

    init(running: Bool, onBreak: Bool) {
        self = !running ? .ready : (onBreak ? .rest : .focus)
    }
}

enum Ink {
    static let primary = Color.white
    static let secondary = Color.white.opacity(0.72)
    static let tertiary = Color.white.opacity(0.5)
    static let fill = Color.white.opacity(0.08)
    static let fillStrong = Color.white.opacity(0.16)
    static let hairline = Color.white.opacity(0.12)
}

struct ImmersiveBackground: View {
    enum Style {
        /// The tray and floating timer: a graphite wash that lets the glass and wallpaper show through.
        case panel
        /// Full windows (onboarding, break screen): graphite with a teal and dawn aurora.
        case vivid
    }

    var style: Style = .panel
    var mood: Mood = .ready
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        GeometryReader { proxy in
            let reach = max(proxy.size.width, proxy.size.height)
            ZStack {
                LinearGradient(colors: [Color(hex: 0x161B26), Color(hex: 0x0B0F16)], startPoint: .top, endPoint: .bottom)
                    .opacity(reduceTransparency ? 1 : (style == .panel ? 0.8 : 0.9))
                switch style {
                case .panel:
                    RadialGradient(colors: [mood.glow.opacity(0.2), .clear],
                                   center: UnitPoint(x: 0.5, y: 0.2), startRadius: 0, endRadius: reach * 0.6)
                    RadialGradient(colors: [Color(hex: 0x4FA8FF, opacity: 0.1), .clear],
                                   center: .bottomTrailing, startRadius: 0, endRadius: reach * 0.7)
                case .vivid:
                    RadialGradient(colors: [Brand.tide[0].opacity(0.3), .clear],
                                   center: .topLeading, startRadius: 0, endRadius: reach * 0.75)
                    RadialGradient(colors: [Brand.dawn[1].opacity(mood == .rest ? 0.32 : 0.18), .clear],
                                   center: .bottomTrailing, startRadius: 0, endRadius: reach * 0.7)
                    RadialGradient(colors: [Color(hex: 0x6366F1, opacity: 0.14), .clear],
                                   center: .center, startRadius: 0, endRadius: reach * 0.5)
                }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: mood)
    }
}

struct FocusRing: View {
    let progress: Double
    let mood: Mood
    var lineWidth: CGFloat = 10
    var glow = true

    var body: some View {
        let clamped = min(max(progress, 0.002), 1)
        // A full ring wraps back to its first colour so there is no seam at twelve o'clock.
        let stops = clamped >= 1 ? mood.colors + [mood.colors[0]] : mood.colors
        ZStack {
            Circle().stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    AngularGradient(colors: stops, center: .center, startAngle: .zero, endAngle: .degrees(360 * clamped)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: glow ? mood.glow.opacity(0.6) : .clear, radius: lineWidth * 1.1)
        }
        .padding(lineWidth / 2)
        .accessibilityHidden(true)
    }
}

/// Rounded-rectangle buttons: the tide call to action, or a translucent secondary.
struct PanelButtonStyle: ButtonStyle {
    enum Kind { case cta, secondary }

    var kind: Kind = .secondary
    var height: CGFloat = 40

    func makeBody(configuration: Configuration) -> some View {
        PanelButton(configuration: configuration, kind: kind, height: height)
    }

    private struct PanelButton: View {
        let configuration: Configuration
        let kind: Kind
        let height: CGFloat
        @Environment(\.isEnabled) private var isEnabled
        @State private var hovering = false

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: 11, style: .continuous)
            configuration.label
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(kind == .cta ? Brand.onAccent : Ink.primary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background {
                    switch kind {
                    case .cta:
                        shape.fill(LinearGradient(colors: Brand.tide, startPoint: .leading, endPoint: .trailing))
                            .brightness(hovering ? 0.05 : 0)
                            .shadow(color: Brand.tide[0].opacity(0.3), radius: 12, y: 3)
                    case .secondary:
                        shape.fill(hovering ? Ink.fillStrong : Ink.fill)
                    }
                }
                .overlay { shape.strokeBorder(kind == .cta ? .clear : Ink.hairline, lineWidth: 0.75) }
                .contentShape(shape)
                .onHover { hovering = $0 }
                .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.4)
                .scaleEffect(configuration.isPressed ? 0.985 : 1)
        }
    }
}

/// A round, haloed primary button for full-window flows.
struct OrbButtonStyle: ButtonStyle {
    var diameter: CGFloat = 76

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background {
                Circle()
                    .fill(LinearGradient(colors: Brand.orb, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: Brand.tide[0].opacity(0.5), radius: 18)
                    .shadow(color: Color(hex: 0x6366F1, opacity: 0.3), radius: 30, x: 10, y: 6)
            }
            .contentShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SquareIconButton: View {
    let symbol: String
    let label: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Ink.primary.opacity(hovering ? 1 : 0.85))
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(colors: [Color.white.opacity(hovering ? 0.24 : 0.18), Color.white.opacity(0.08)],
                                   startPoint: .top, endPoint: .bottom),
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Ink.hairline, lineWidth: 0.5))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(label)
        .accessibilityLabel(label)
    }
}

/// A translucent card in the tray's grid: glyph, title, a coloured status line, and an optional cyan action.
struct ActionCard: View {
    let symbol: String
    let title: String
    let value: Text
    var action: (label: String, run: () -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Ink.primary.opacity(0.9))
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Ink.primary)
                        .lineLimit(1)
                    value
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
            if let action {
                HStack {
                    Spacer()
                    Button(action.label, action: action.run)
                        .buttonStyle(.plain)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Brand.accent)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .topLeading)
        .background(Ink.fill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Ink.hairline, lineWidth: 0.5))
    }
}

/// Rounded-square icon chip used in lists (onboarding helpers).
struct IconChip: View {
    let symbol: String
    var size: CGFloat = 28

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(LinearGradient(colors: Brand.tide, startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous).strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5))
            .accessibilityHidden(true)
    }
}

struct AppMark: View {
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: "timer")
            .font(.system(size: size * 0.52, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: Brand.orb, startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous).strokeBorder(Color.white.opacity(0.35), lineWidth: 0.5))
            .shadow(color: Brand.tide[0].opacity(0.4), radius: size * 0.3)
            .accessibilityHidden(true)
    }
}
