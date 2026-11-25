import SwiftUI
import AppKit
import Combine
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var onboardingWindow: NSWindow?
    let settings = Settings()
    let timerManager: TimerManager
    let soundManager = SoundManager()
    let calendarManager = CalendarManager()
    let focusMonitor = FocusMonitor()
    let agentWatch = AgentWatch()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        self.timerManager = TimerManager(settings: settings)
        super.init()
        self.timerManager.soundManager = soundManager
        agentWatch.soundManager = soundManager
        agentWatch.focusMonitor = focusMonitor
    }

    // Handling the URL event ourselves keeps SwiftUI's WindowGroup from opening a window for every focusly:// URL.
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURL(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    @objc private func handleGetURL(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        guard let string = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
              let url = URL(string: string) else { return }
        agentWatch.handle(url: url)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppSetupManager.shared.performFirstLaunchSetup()
        AppSetupManager.shared.handleAppUpdate()
        UNUserNotificationCenter.current().delegate = self

        setupStatusItem()
        setupKeyboardShortcuts()
        WindowManager.shared.configure(
            settings: settings,
            timerManager: timerManager,
            calendarManager: calendarManager,
            focusMonitor: focusMonitor,
            agentWatch: agentWatch
        )

        hideDefaultWindow()

        if AppSetupManager.shared.shouldShowOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboarding()
            }
        } else if settings.showTimeDisplay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WindowManager.shared.showTimeDisplay()
            }
        }

        NSApp.setActivationPolicy(.accessory)

        NSApp.windows.forEach { window in
            if !(window is TimeOverlayWindow) {
                window.setIsVisible(false)
                window.orderOut(nil)
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(closePopover),
            name: NSNotification.Name("ClosePopover"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ToggleTimeDisplay"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.settings.showTimeDisplay.toggle()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPopover),
            name: NSNotification.Name("OpenMainPopover"),
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyboardShortcutManager.shared.unregisterGlobalShortcuts()
        WindowManager.shared.cleanup()
    }

    // Menu bar app: closing the onboarding window or the last overlay must not quit it.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func setupKeyboardShortcuts() {
        KeyboardShortcutManager.shared.timerManager = timerManager
        KeyboardShortcutManager.shared.registerGlobalShortcuts()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Focusly")
            button.action = #selector(togglePopover)
            button.target = self
        }

        let hostingController = NSHostingController(rootView: MenuBarView()
            .environmentObject(settings)
            .environmentObject(timerManager)
            .environmentObject(soundManager)
            .environmentObject(calendarManager))
        hostingController.sizingOptions = .preferredContentSize

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = hostingController
        self.popover = popover

        timerManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateStatusBarIcon() }
            .store(in: &cancellables)

        timerManager.$isRunning
            .removeDuplicates()
            .filter { $0 }
            .first()
            .sink { _ in
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
            }
            .store(in: &cancellables)

        timerManager.$isRunning
            .combineLatest(timerManager.$isBreakTime)
            .map { running, onBreak in running && !onBreak }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] focusing in
                if focusing {
                    self?.focusMonitor.start()
                } else {
                    self?.focusMonitor.stop()
                }
            }
            .store(in: &cancellables)
    }

    private func updateStatusBarIcon() {
        guard let button = statusItem?.button else { return }
        if !timerManager.isRunning {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Focusly")
        } else if timerManager.isBreakTime {
            button.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Focusly, on break")
        } else {
            button.image = NSImage(systemSymbolName: "timer.circle.fill", accessibilityDescription: "Focusly, focusing")
        }
    }

    @objc func togglePopover() {
        if popover?.isShown == true {
            closePopover()
        } else {
            showPopover()
        }
    }

    @objc func showPopover() {
        guard let button = statusItem?.button, let popover, !popover.isShown else { return }
        // An accessory app must be active for the popover's text fields to take keyboard focus.
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    @objc func closePopover() {
        popover?.performClose(nil)
    }

    // MARK: - Onboarding

    func showOnboarding() {
        let onboardingView = OnboardingView { [weak self] startNow in
            self?.finishOnboarding(startNow: startNow)
        }
        .environmentObject(settings)
        .environmentObject(timerManager)
        .environmentObject(calendarManager)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Welcome to Focusly"
        let host = NSHostingView(rootView: onboardingView)
        host.frame = NSRect(x: 0, y: 0, width: 460, height: 420)
        host.autoresizingMask = [.width, .height]
        window.setGlassContent(host, cornerRadius: 16)
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.delegate = self
        window.center()
        onboardingWindow = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func finishOnboarding(startNow: Bool) {
        guard let window = onboardingWindow else { return }
        onboardingWindow = nil
        window.close()
        AppSetupManager.shared.completeOnboarding()

        if settings.showTimeDisplay {
            WindowManager.shared.showTimeDisplay()
        }
        if startNow {
            timerManager.start()
        }
    }

    private func hideDefaultWindow() {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { $0.contentViewController is NSHostingController<MinimalView> }) {
                window.orderOut(nil)
                window.setIsVisible(false)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Show banners even while the popover has Focusly frontmost.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == AgentWatch.notificationID {
            DispatchQueue.main.async { self.agentWatch.returnToAgent() }
        }
        completionHandler()
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) === onboardingWindow {
            finishOnboarding(startNow: false)
        }
    }
}

struct MinimalView: View {
    var body: some View {
        EmptyView()
            .frame(maxWidth: 0, maxHeight: 0)
            .background(.clear)
    }
}

@main
struct FocuslyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MinimalView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 0, height: 0)
    }
}
