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
    func glassBackground(in shape: some Shape, interactive: Bool = false) -> some View {
        modifier(GlassBackground(shape: shape, interactive: interactive))
    }
}

private struct GlassBackground<S: Shape>: ViewModifier {
    let shape: S
    let interactive: Bool
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.glassEffect(.regular.interactive(interactive), in: shape)
        } else if reduceTransparency {
            content.background(Color(nsColor: .windowBackgroundColor), in: shape)
        } else {
            content.background {
                shape.fill(.regularMaterial)
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

// MARK: - Minimal surfaces
// Native glass and the system light/dark appearance; monochrome ink, one inverted primary action,
// and colour only for warnings that matter.

enum Ink {
    static let primary = Color.primary
    static let secondary = Color.secondary
    static let fill = Color.primary.opacity(0.05)
    static let fillStrong = Color.primary.opacity(0.1)
    static let hairline = Color.primary.opacity(0.08)
}

enum Signal {
    static let soon = Color.orange
    static let now = Color.red
}

enum Mood {
    case ready, focus, rest

    /// The word in "Focus: Ready".
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

struct FocusRing: View {
    let progress: Double
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle().stroke(Ink.fillStrong, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Ink.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(lineWidth / 2)
        .accessibilityHidden(true)
    }
}

/// Rounded-rectangle buttons: the inverted primary action, or a quiet secondary.
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
            let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
            Group {
                if kind == .cta {
                    configuration.label.foregroundStyle(.background)
                } else {
                    configuration.label.foregroundStyle(Ink.primary)
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                if kind == .cta {
                    shape.fill(Ink.primary.opacity(hovering ? 0.85 : 1))
                } else {
                    shape.fill(hovering ? Ink.fillStrong : Ink.fill)
                }
            }
            .overlay { shape.strokeBorder(kind == .cta ? .clear : Ink.hairline, lineWidth: 0.5) }
            .contentShape(shape)
            .onHover { hovering = $0 }
            .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.35)
        }
    }
}

/// A round primary button for full-window flows.
struct OrbButtonStyle: ButtonStyle {
    var diameter: CGFloat = 64

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.background)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Ink.primary))
            .contentShape(Circle())
            .opacity(configuration.isPressed ? 0.8 : 1)
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
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(hovering ? Ink.primary : Ink.secondary)
                .frame(width: 28, height: 28)
                .background(hovering ? Ink.fillStrong : Ink.fill, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(label)
        .accessibilityLabel(label)
    }
}

/// A quiet card in the tray's grid: glyph, title, a status line, and an optional text action.
struct ActionCard: View {
    let symbol: String
    let title: String
    let value: Text
    var action: (label: String, run: () -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Ink.secondary)
                    .frame(width: 18, height: 18)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Ink.primary)
                        .lineLimit(1)
                    value
                        .font(.system(size: 12))
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
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Ink.primary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .background(Ink.fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Rounded-square icon chip used in lists (onboarding helpers).
struct IconChip: View {
    let symbol: String
    var size: CGFloat = 28

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.42, weight: .medium))
            .foregroundStyle(Ink.primary)
            .frame(width: size, height: size)
            .background(Ink.fillStrong, in: RoundedRectangle(cornerRadius: size * 0.26, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct AppMark: View {
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: "timer")
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(.background)
            .frame(width: size, height: size)
            .background(Ink.primary, in: RoundedRectangle(cornerRadius: size * 0.26, style: .continuous))
            .accessibilityHidden(true)
    }
}
