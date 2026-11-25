import Foundation

/// First-run and version bookkeeping, plus whether onboarding has been seen.
class AppSetupManager {
    static let shared = AppSetupManager()

    private let defaults = UserDefaults.app
    private let currentVersion = "1.0.0"
    private let currentBuildNumber = "5"

    private init() {}

    var shouldShowOnboarding: Bool {
        !defaults.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding() {
        defaults.set(true, forKey: "hasCompletedOnboarding")
        defaults.set(Date(), forKey: "onboardingCompletedDate")
        defaults.set(currentVersion, forKey: "onboardedAppVersion")
    }

    func performFirstLaunchSetup() {
        guard defaults.object(forKey: "firstLaunchDate") == nil else { return }
        defaults.set(Date(), forKey: "firstLaunchDate")
        defaults.set(currentVersion, forKey: "firstAppVersion")
        defaults.set(currentVersion, forKey: "lastAppVersion")
        defaults.set(currentBuildNumber, forKey: "lastBuildNumber")
    }

    func handleAppUpdate() {
        guard let lastVersion = defaults.string(forKey: "lastAppVersion"), lastVersion != currentVersion else { return }
        defaults.set(currentVersion, forKey: "lastAppVersion")
        defaults.set(currentBuildNumber, forKey: "lastBuildNumber")
        defaults.set(Date(), forKey: "lastUpdateDate")
    }
}
