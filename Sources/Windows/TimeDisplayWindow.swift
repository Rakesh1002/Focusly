import SwiftUI
import AppKit

final class TimeOverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 40),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        // WindowManager owns these windows and closes them on display changes; AppKit must not also release them.
        isReleasedWhenClosed = false
        backgroundColor = .clear
        isOpaque = false
        level = .floating
        collectionBehavior = [.canJoinAllSpaces]
        isMovableByWindowBackground = true
        place(on: screen)
    }

    func place(on screen: NSScreen) {
        let visible = screen.visibleFrame
        setFrameOrigin(NSPoint(x: visible.maxX - frame.width - 20, y: visible.maxY - frame.height - 20))
    }
}

struct TimeDisplayWindow: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(timeString(from: currentTime))
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.white)

            if timerManager.isRunning {
                Text(formatTime(timerManager.remainingTime))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(timerManager.isBreakTime ? .mint : .orange)
            }
        }
        .padding(8)
        .frame(width: 120)
        .background(Color.black.opacity(0.75))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            NotificationCenter.default.post(name: NSNotification.Name("OpenMainPopover"), object: nil)
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
