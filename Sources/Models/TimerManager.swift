import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var remainingTime: TimeInterval
    @Published var isBreakTime = false

    private(set) var settings: Settings
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var workDuration: TimeInterval { settings.workDuration }
    private var breakDuration: TimeInterval { settings.breakDuration }

    var soundManager: SoundManager?

    init(settings: Settings) {
        self.settings = settings
        self.remainingTime = settings.workDuration
        settings.$workDuration
            .dropFirst()
            .sink { [weak self] duration in
                guard let self = self, !self.isRunning, !self.isBreakTime else { return }
                self.remainingTime = duration
            }
            .store(in: &cancellables)
    }

    func start() {
        guard !isRunning else { return }
        if remainingTime == 0 {
            remainingTime = workDuration
        }
        isRunning = true
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.handleTimerComplete()
            }
        }
        // .common keeps the countdown ticking while menus or the popover are tracking events.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        if isBreakTime {
            isBreakTime = false
            WindowManager.shared.hideBreakOverlay()
        }
        remainingTime = workDuration
    }

    func handleTimerComplete() {
        if isBreakTime {
            stop()
            notify(id: "breakComplete", title: "Break is over", body: "Ready when you are.")
            soundManager?.playBreakCompleteSound()
        } else {
            isBreakTime = true
            remainingTime = breakDuration
            if settings.showBreakOverlay {
                WindowManager.shared.showBreakOverlay()
            }
            notify(id: "breakTime", title: "Time for a break", body: "Step away for \(Int(breakDuration / 60)) minutes.")
            soundManager?.playWorkCompleteSound()
        }
    }

    func skipBreakStartWork() {
        guard isBreakTime else { return }
        isBreakTime = false
        remainingTime = workDuration
        WindowManager.shared.hideBreakOverlay()
        if timer == nil {
            start()
        }
    }

    private func notify(id: String, title: String, body: String) {
        guard settings.breakNotifications else { return }
        Notifier.send(id: id, title: title, body: body)
    }

    deinit {
        timer?.invalidate()
    }
}
