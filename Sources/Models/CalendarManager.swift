import Foundation
import EventKit
import AppKit

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendar: String
}

class CalendarManager: ObservableObject {
    @Published var hasAccess = false
    @Published var upcomingEvents: [CalendarEvent] = []
    
    private let eventStore = EKEventStore()
    private var timer: Timer?
    var useMockData = false  // Set to true for screenshots
    
    init() {
        #if DEBUG
        useMockData = UserDefaults.app.bool(forKey: "useMockCalendarData")
        #else
        useMockData = false
        #endif

        if useMockData {
            hasAccess = true
            loadMockEvents()
        } else {
            checkCalendarAccess()
        }
        startEventRefresh()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Mock Data for Screenshots
    
    func loadMockEvents() {
        let now = Date()
        let calendar = Calendar.current
        
        upcomingEvents = [
            CalendarEvent(
                id: "1",
                title: "Team Standup",
                startDate: calendar.date(byAdding: .hour, value: 1, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .minute, value: 15, to: now)!)!,
                isAllDay: false,
                calendar: "Work"
            ),
            CalendarEvent(
                id: "2",
                title: "Design Review",
                startDate: calendar.date(byAdding: .hour, value: 3, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: 4, to: now)!,
                isAllDay: false,
                calendar: "Work"
            ),
            CalendarEvent(
                id: "3",
                title: "Lunch Break",
                startDate: calendar.date(byAdding: .hour, value: 5, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: 6, to: now)!,
                isAllDay: false,
                calendar: "Personal"
            ),
            CalendarEvent(
                id: "4",
                title: "Client Call",
                startDate: calendar.date(byAdding: .hour, value: 7, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: 8, to: now)!,
                isAllDay: false,
                calendar: "Work"
            ),
            CalendarEvent(
                id: "5",
                title: "Project Planning Meeting",
                startDate: calendar.date(byAdding: .day, value: 1, to: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!)!,
                endDate: calendar.date(byAdding: .hour, value: 2, to: calendar.date(byAdding: .day, value: 1, to: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!)!)!,
                isAllDay: false,
                calendar: "Work"
            )
        ]
    }
    
    // MARK: - Calendar Access
    
    func checkCalendarAccess() {
        if useMockData {
            hasAccess = true
            loadMockEvents()
            return
        }
        if #available(macOS 14.0, *) {
            switch EKEventStore.authorizationStatus(for: .event) {
            case .fullAccess, .authorized:
                hasAccess = true
                fetchUpcomingEvents()
            case .notDetermined:
                // Will request when button is clicked
                hasAccess = false
            case .denied, .restricted, .writeOnly:
                hasAccess = false
            @unknown default:
                hasAccess = false
            }
        } else {
            switch EKEventStore.authorizationStatus(for: .event) {
            case .authorized:
                hasAccess = true
                fetchUpcomingEvents()
            case .notDetermined:
                hasAccess = false
            case .denied, .restricted:
                hasAccess = false
            case .fullAccess, .writeOnly:
                // These cases exist in newer macOS versions but we're in the else block for older versions
                hasAccess = false
            @unknown default:
                hasAccess = false
            }
        }
    }
    
    func requestCalendarAccess() {
        if #available(macOS 14.0, *) {
            // Modern API for macOS 14+
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.fetchUpcomingEvents()
                    }
                    if let error = error {
                        print("Calendar access error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Legacy API for macOS 13 and earlier
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.fetchUpcomingEvents()
                    }
                    if let error = error {
                        print("Calendar access error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Asks once; after a denial the system won't ask again, so send the user to Privacy settings instead.
    func connect() {
        if accessStatus == .notDetermined {
            requestCalendarAccess()
        } else {
            openSystemPreferences()
        }
    }

    func openSystemPreferences() {
        // Use the x-apple.systempreferences URL scheme (allowed in sandboxed apps)
        // This works for both macOS 13+ (System Settings) and earlier versions (System Preferences)
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    var accessStatus: EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - Fetch Events
    
    func fetchUpcomingEvents() {
        guard hasAccess else { return }
        
        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: calendars)
        
        let ekEvents = eventStore.events(matching: predicate)
        
        upcomingEvents = ekEvents.map { event in
            CalendarEvent(
                id: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                calendar: event.calendar.title
            )
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private func startEventRefresh() {
        // Invalidate existing timer first to prevent duplicates
        timer?.invalidate()
        timer = nil
        
        // Refresh events every 5 minutes
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            if self?.useMockData == true {
                self?.loadMockEvents()
            } else {
                self?.fetchUpcomingEvents()
            }
        }
    }

    /// Computed from the cached list at call time so a meeting that has started drops out between 5-minute refreshes.
    func nextEvent(after date: Date = Date()) -> CalendarEvent? {
        upcomingEvents.first { !$0.isAllDay && $0.startDate > date }
    }
}
