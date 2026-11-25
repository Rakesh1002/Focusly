import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var remainingTime: TimeInterval
    @Published var isBreakTime = false
    @Published var task: String {
        didSet { defaults.set(task, forKey: "focusTask") }
    }
    @Published private(set) var recentTasks: [String]
    @Published private(set) var lastNote: String
    @Published var awaitingNote = false

    private(set) var settings: Settings
    private let defaults: UserDefaults
    private var timer: Timer?
    private var endDate: Date?
    private var activity: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var workDuration: TimeInterval { settings.workDuration }
    private var breakDuration: TimeInterval { settings.breakDuration }

    var soundManager: SoundManager?

    init(settings: Settings, defaults: UserDefaults = .app) {
        self.settings = settings
        self.defaults = defaults
        self.remainingTime = settings.workDuration
        self.task = defaults.string(forKey: "focusTask") ?? ""
        self.recentTasks = defaults.stringArray(forKey: "recentFocusTasks") ?? []
        self.lastNote = defaults.string(forKey: "reentryNote") ?? ""
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
        rememberTask()
        awaitingNote = false
        isRunning = true
        endDate = Date().addingTimeInterval(remainingTime)
        // Without this App Nap throttles the tick in the background and the anchor's countdown falls behind.
        activity = ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "Focus session running")
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // .common keeps the countdown ticking while menus or the popover are tracking events.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        if isRunning && !isBreakTime {
            awaitingNote = true
        }
        isRunning = false
        timer?.invalidate()
        timer = nil
        endDate = nil
        if let activity {
            ProcessInfo.processInfo.endActivity(activity)
            self.activity = nil
        }
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
            awaitingNote = true
            remainingTime = breakDuration
            endDate = Date().addingTimeInterval(breakDuration)
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
        awaitingNote = false
        remainingTime = workDuration
        endDate = Date().addingTimeInterval(workDuration)
        WindowManager.shared.hideBreakOverlay()
        if timer == nil {
            start()
        }
    }

    // Counts down from a fixed end date so late ticks never stretch a block.
    private func tick() {
        guard let endDate else { return }
        remainingTime = max(0, endDate.timeIntervalSinceNow.rounded())
        if remainingTime == 0 {
            handleTimerComplete()
        }
    }

    func saveNote(_ note: String) {
        lastNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        defaults.set(lastNote, forKey: "reentryNote")
        awaitingNote = false
    }

    private func rememberTask() {
        let trimmed = task.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentTasks = Array(([trimmed] + recentTasks.filter { $0 != trimmed }).prefix(5))
        defaults.set(recentTasks, forKey: "recentFocusTasks")
    }

    private func notify(id: String, title: String, body: String) {
        guard settings.breakNotifications else { return }
        Notifier.send(id: id, title: title, body: body)
    }

    deinit {
        timer?.invalidate()
        if let activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
    }
}
