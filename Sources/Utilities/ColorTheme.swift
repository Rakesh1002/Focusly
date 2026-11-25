import SwiftUI
import AppKit

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
}

enum Radius {
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 24
}

extension Font {
    static let timer = Font.system(.largeTitle, design: .rounded).monospacedDigit()
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

    @ViewBuilder func glassButton(prominent: Bool = false) -> some View {
        if #available(macOS 26, *) {
            if prominent { buttonStyle(.glassProminent) } else { buttonStyle(.glass) }
        } else {
            if prominent { buttonStyle(.borderedProminent) } else { buttonStyle(.bordered) }
        }
    }

    @ViewBuilder func glassGroup() -> some View {
        if #available(macOS 26, *) {
            GlassEffectContainer { self }
        } else {
            self
        }
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
            content.background(.regularMaterial, in: shape)
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
