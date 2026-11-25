import SwiftUI

enum MenuBarTab {
    case main
    case settings
}

struct MenuBarView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var timerManager: TimerManager
    @State private var currentTab: MenuBarTab = .main
    
    var body: some View {
        VStack(spacing: 0) {
            // Content with vibrant background
            Group {
                switch currentTab {
                case .main:
                    mainView
                case .settings:
                    SettingsView(isPresented: Binding(
                        get: { currentTab == .settings },
                        set: { if !$0 { currentTab = .main } }
                    ))
                    .frame(height: 500)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
            
            // Bottom navigation with glass effect
            HStack(spacing: 8) {
                if currentTab != .main {
                    Button(action: { currentTab = .main }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .help("Back")
                }
                
                Spacer()
                
                // Show Quit on Settings screen, Settings button otherwise
                if currentTab == .settings {
                    Button(action: { NSApplication.shared.terminate(nil) }) {
                        Image(systemName: "power")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red.opacity(0.9))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .help("Quit Focusly")
                } else {
                    Button(action: { currentTab = .settings }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.cardBackground)
        }
    }
    
    private var mainView: some View {
        VStack(spacing: 12) {
            Text(timerManager.isBreakTime ? "Break Time!" : "Focus Time")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
            
            Text(formatTime(timerManager.remainingTime))
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(timerManager.isBreakTime ? Color.accentOrange : Color.accentBlue)
                .padding(.vertical, 12)
                .shadow(color: (timerManager.isBreakTime ? Color.accentOrange : Color.accentBlue).opacity(0.3), radius: 20, y: 0)
                .scaleEffect(timerManager.isRunning ? 1.0 : 0.98)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: timerManager.isRunning)
            
            // Primary Action - Following Apple HIG for critical actions
            VStack(spacing: 12) {
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.stop()
                    } else {
                        timerManager.start()
                        // Close popover when starting timer
                        NotificationCenter.default.post(name: NSNotification.Name("ClosePopover"), object: nil)
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: timerManager.isRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text(timerManager.isRunning ? "Stop" : "Start")
                            .font(.system(size: 19, weight: .bold))
                    }
                    .frame(width: 200, height: 56)
                    .foregroundStyle(.white)
                }
                .buttonStyle(PrimaryButtonStyle(color: timerManager.isRunning ? .statusError : .statusSuccess))
                .shadow(color: (timerManager.isRunning ? Color.statusError : Color.statusSuccess).opacity(0.4), radius: 12, y: 6)
                
                if timerManager.isBreakTime {
                    Button("Skip Break") {
                        timerManager.skipBreakStartWork()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .transition(.smoothScale)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .onChange(of: settings.showFloatingTimerOnAllScreens) { _ in
            if settings.showTimeDisplay {
                WindowManager.shared.showTimeDisplay()
            }
        }
        .onChange(of: settings.showBreakOverlay) { show in
            if !show {
                WindowManager.shared.hideBreakOverlay()
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
