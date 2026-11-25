import SwiftUI
import AppKit

struct BreakOverlayView: View {
    @EnvironmentObject var timerManager: TimerManager

    private var progress: Double {
        let total = timerManager.settings.breakDuration
        guard total > 0 else { return 0 }
        return 1 - timerManager.remainingTime / total
    }

    var body: some View {
        ZStack {
            Color(hex: 0x0B0F16)
            ImmersiveBackground(style: .vivid, mood: .rest)
            VStack(spacing: Spacing.xl) {
                Text("Take a break")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Ink.primary)
                ZStack {
                    FocusRing(progress: progress, mood: .rest, lineWidth: 14)
                    Text(timerManager.remainingTime.clock)
                        .font(.system(size: 72, weight: .light, design: .rounded).monospacedDigit())
                        .foregroundStyle(Ink.primary)
                }
                .frame(width: 280, height: 280)
                Text("Step away from the screen. Your task will be here when you get back.")
                    .font(.system(size: 16))
                    .foregroundStyle(Ink.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
                HStack(spacing: Spacing.m) {
                    Button("End session") { timerManager.stop() }
                        .buttonStyle(PanelButtonStyle(height: 44))
                    Button("Skip break") { timerManager.skipBreakStartWork() }
                        .buttonStyle(PanelButtonStyle(kind: .cta, height: 44))
                }
                .frame(width: 360)
            }
        }
        .environment(\.colorScheme, .dark)
    }
}

final class BreakOverlayWindow: NSWindow {
    init(screen: NSScreen, timerManager: TimerManager) {
        super.init(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        isReleasedWhenClosed = false
        // Above notification banners and every app, on every Space, and pinned through Mission Control.
        level = .screenSaver
        backgroundColor = .black
        isOpaque = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        let host = NSHostingView(rootView: BreakOverlayView().environmentObject(timerManager))
        // Keep the window screen-sized; by default the hosting view would shrink it to the content.
        host.sizingOptions = []
        contentView = host
        setFrame(screen.frame, display: false)
    }

    override var canBecomeKey: Bool { true }
}
