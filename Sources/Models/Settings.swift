import Foundation
import ServiceManagement

class Settings: ObservableObject {
    private var isInitialized = false  // Track initialization state
    
    @Published var workDuration: TimeInterval {
        didSet { saveSettings() }
    }
    
    @Published var breakDuration: TimeInterval {
        didSet { saveSettings() }
    }
    
    @Published var showTimeDisplay: Bool {
        didSet {
            saveSettings()
            guard isInitialized else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.showTimeDisplay {
                    WindowManager.shared.showTimeDisplay()
                } else {
                    WindowManager.shared.hideTimeDisplay()
                }
            }
        }
    }
    
    @Published var showBreakOverlay: Bool {
        didSet { saveSettings() }
    }
    
    @Published var breakNotifications: Bool {
        didSet { saveSettings() }
    }
    
    @Published var launchAtLogin: Bool {
        didSet {
            setLaunchAtLogin(launchAtLogin)
            saveSettings()
        }
    }
    
    @Published var showFloatingTimerOnAllScreens: Bool {
        didSet { saveSettings() }
    }
    
    private let defaults = UserDefaults.app
    
    init() {
        // Default to 50 minutes work duration
        self.workDuration = defaults.double(forKey: "workDuration").nonZero ?? 50 * 60
        self.breakDuration = defaults.double(forKey: "breakDuration").nonZero ?? 10 * 60
        
        // All display and notification features enabled by default
        self.showTimeDisplay = defaults.object(forKey: "showTimeDisplay") as? Bool ?? true
        self.showBreakOverlay = defaults.object(forKey: "showBreakOverlay") as? Bool ?? true
        self.breakNotifications = defaults.object(forKey: "breakNotifications") as? Bool ?? true
        
        // Launch at login - default to false (user must explicitly enable per App Store guidelines)
        self.launchAtLogin = defaults.object(forKey: "launchAtLogin") as? Bool ?? false
        
        // Show floating timer on all screens - default to true for better visibility
        self.showFloatingTimerOnAllScreens = defaults.object(forKey: "showFloatingTimerOnAllScreens") as? Bool ?? true
        
        // Only auto-register if user previously enabled it
        // Do NOT auto-enable on first launch (App Store guideline 2.4.5(iii))
        if self.launchAtLogin {
            // If launch at login is enabled in settings, ensure it's actually registered
            // This handles cases where the setting is ON but registration was lost
            ensureLaunchAtLoginRegistered()
        }
        
        // Mark as initialized - now didSet handlers can trigger WindowManager
        isInitialized = true
    }
    
    // Make this public so it can be called from MenuBarView
    func saveSettings() {
        defaults.set(workDuration, forKey: "workDuration")
        defaults.set(breakDuration, forKey: "breakDuration")
        defaults.set(showTimeDisplay, forKey: "showTimeDisplay")
        defaults.set(showBreakOverlay, forKey: "showBreakOverlay")
        defaults.set(breakNotifications, forKey: "breakNotifications")
        defaults.set(launchAtLogin, forKey: "launchAtLogin")
        defaults.set(showFloatingTimerOnAllScreens, forKey: "showFloatingTimerOnAllScreens")
    }
    
    // MARK: - Launch at Login
    
    /// Re-registers silently when the setting is on but the system lost the login item.
    private func ensureLaunchAtLoginRegistered() {
        guard SMAppService.mainApp.status != .enabled else { return }
        try? SMAppService.mainApp.register()
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        let status = SMAppService.mainApp.status
        do {
            if enabled && status != .enabled {
                try SMAppService.mainApp.register()
            } else if !enabled && status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Focusly: launch at login change failed: %@", error.localizedDescription)
        }
    }
}

extension Double {
    var nonZero: Double? {
        return self == 0 ? nil : self
    }
}
