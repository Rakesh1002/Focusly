import SwiftUI
import AppKit

struct BreakOverlayView: View {
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: Spacing.l) {
                Text("Break")
                    .font(.largeTitle.weight(.semibold))
                Text(timerManager.remainingTime.clock)
                    .font(.system(size: 72, weight: .semibold, design: .rounded).monospacedDigit())
                Text("Step away from the screen. Your task will be here when you get back.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: Spacing.m) {
                    Button("End session") { timerManager.stop() }
                        .foregroundStyle(.primary)
                        .glassButton()
                    Button("Skip break") { timerManager.skipBreakStartWork() }
                        .glassButton(prominent: true)
                }
                .controlSize(.large)
                .glassGroup()
                .padding(.top, Spacing.s)
            }
            .padding(Spacing.xl * 2)
            .frame(maxWidth: 520)
            .glassBackground(in: RoundedRectangle(cornerRadius: Radius.l))
        }
    }
}

final class BreakOverlayWindow: NSWindow {
    init(screen: NSScreen, timerManager: TimerManager) {
        super.init(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        isReleasedWhenClosed = false
        level = .popUpMenu
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let host = NSHostingView(rootView: BreakOverlayView().environmentObject(timerManager))
        // Keep the window screen-sized; by default the hosting view would shrink it to the content.
        host.sizingOptions = []
        contentView = host
        setFrame(screen.frame, display: false)
    }

    override var canBecomeKey: Bool { true }
}
