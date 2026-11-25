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
            NSLog("⚙️ Settings: showTimeDisplay changed to \(showTimeDisplay), isInitialized: \(isInitialized)")
            saveSettings()
            
            // Only control WindowManager if we're fully initialized
            guard isInitialized else {
                NSLog("⚙️ Settings: Skipping WindowManager call - not yet initialized")
                return
            }
            
            // Use async to avoid potential crashes during property observation
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.showTimeDisplay {
                    NSLog("⚙️ Settings: Calling showTimeDisplay()")
                    WindowManager.shared.showTimeDisplay()
                } else {
                    NSLog("⚙️ Settings: Calling hideTimeDisplay()")
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
        NSLog("⚙️ Settings: Initialization complete, showTimeDisplay = \(showTimeDisplay)")
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
    
    /// Ensures launch at login is registered if the setting is enabled
    /// Called on app startup to silently fix registration issues
    private func ensureLaunchAtLoginRegistered() {
        if #available(macOS 13.0, *) {
            let currentStatus = SMAppService.mainApp.status
            
            // If setting is ON but not registered/enabled, try to register silently
            if currentStatus != .enabled {
                do {
                    try SMAppService.mainApp.register()
                    print("✅ Auto-registered launch at login on startup")
                } catch {
                    print("ℹ️ Launch at login auto-registration: \(error.localizedDescription)")
                    // Don't show error on startup - only show when user manually toggles
                }
            }
        }
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                let currentStatus = SMAppService.mainApp.status
                print("📱 Current launch at login status: \(currentStatus.rawValue)")
                
                if enabled {
                    // Register if not already enabled
                    if currentStatus != .enabled {
                        try SMAppService.mainApp.register()
                        print("✅ Launch at login enabled")
                        
                        // Log status but don't show UI (auto-registration handles it)
                        let newStatus = SMAppService.mainApp.status
                        print("ℹ️ Launch at login status after registration: \(newStatus.rawValue)")
                    } else {
                        print("ℹ️ Launch at login already enabled")
                    }
                } else {
                    // Unregister if currently enabled
                    if currentStatus == .enabled {
                        try SMAppService.mainApp.unregister()
                        print("⛔ Launch at login disabled")
                    }
                }
            } catch {
                print("❌ Failed to set launch at login: \(error.localizedDescription)")
            }
        } else {
            // Fallback for older macOS versions
            print("⚠️ Launch at login requires macOS 13.0 or later")
        }
    }
}

extension Double {
    var nonZero: Double? {
        return self == 0 ? nil : self
    }
}
