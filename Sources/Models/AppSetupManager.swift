import Foundation

/// Handles first-run setup, onboarding, and data migration across app versions
class AppSetupManager {
    static let shared = AppSetupManager()
    
    private let defaults = UserDefaults.app
    private let currentVersion = "1.0.0"
    private let currentBuildNumber = "5"
    
    private init() {}
    
    // MARK: - Onboarding
    
    /// Check if user needs to see onboarding
    var shouldShowOnboarding: Bool {
        return !defaults.bool(forKey: "hasCompletedOnboarding")
    }
    
    /// Mark onboarding as completed
    func completeOnboarding() {
        defaults.set(true, forKey: "hasCompletedOnboarding")
        defaults.set(Date(), forKey: "onboardingCompletedDate")
        defaults.set(currentVersion, forKey: "onboardedAppVersion")
        print("✅ Onboarding completed for version \(currentVersion)")
    }
    
    // MARK: - App Updates
    
    /// Check if this is a fresh install
    var isFreshInstall: Bool {
        return defaults.object(forKey: "firstLaunchDate") == nil
    }
    
    /// Check if app was updated
    var isAppUpdated: Bool {
        guard let lastVersion = defaults.string(forKey: "lastAppVersion") else {
            return false
        }
        return lastVersion != currentVersion
    }
    
    /// Perform first launch setup
    func performFirstLaunchSetup() {
        guard isFreshInstall else { return }
        
        print("🎉 First launch detected - performing initial setup")
        
        defaults.set(Date(), forKey: "firstLaunchDate")
        defaults.set(currentVersion, forKey: "firstAppVersion")
        defaults.set(currentVersion, forKey: "lastAppVersion")
        defaults.set(currentBuildNumber, forKey: "lastBuildNumber")
        
        print("✅ First launch setup complete")
    }
    
    /// Handle app update
    func handleAppUpdate() {
        guard isAppUpdated else { return }
        
        let lastVersion = defaults.string(forKey: "lastAppVersion") ?? "unknown"
        print("📦 App updated from \(lastVersion) to \(currentVersion)")
        
        // Perform version-specific migrations
        performDataMigration(from: lastVersion, to: currentVersion)
        
        // Update version tracking
        defaults.set(currentVersion, forKey: "lastAppVersion")
        defaults.set(currentBuildNumber, forKey: "lastBuildNumber")
        defaults.set(Date(), forKey: "lastUpdateDate")
        
        print("✅ App update handled successfully")
    }
    
    // MARK: - Data Migration
    
    /// Migrate data between versions if needed
    private func performDataMigration(from oldVersion: String, to newVersion: String) {
        print("🔄 Checking for data migrations...")
        
        // Example migration patterns:
        // if oldVersion < "1.1.0" {
        //     migrateToV1_1_0()
        // }
        
        // For now, just ensure data integrity
        validateUserData()
        
        print("✅ Data migration complete")
    }
    
    /// Validate and repair user data if needed
    private func validateUserData() {
        // Ensure critical values have sensible defaults
        
        // Work duration must be positive
        let workDuration = defaults.double(forKey: "workDuration")
        if workDuration <= 0 {
            defaults.set(50 * 60, forKey: "workDuration") // 50 minutes default
            print("⚠️ Reset invalid work duration to default")
        }
        
        // Break duration must be positive
        let breakDuration = defaults.double(forKey: "breakDuration")
        if breakDuration <= 0 {
            defaults.set(10 * 60, forKey: "breakDuration") // 10 minutes default
            print("⚠️ Reset invalid break duration to default")
        }
    }
}
