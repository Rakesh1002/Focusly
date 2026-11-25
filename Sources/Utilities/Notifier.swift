import UserNotifications

enum Notifier {
    // Swapped out in tests: UNUserNotificationCenter throws when the process has no app bundle.
    // Asking is a no-op once the user has answered; agent-only users never press Start, so ask before the first post too.
    static var post: (UNNotificationRequest) -> Void = { request in
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in center.add(request) }
    }

    static var requestAuthorization: (@escaping (Bool) -> Void) -> Void = { done in
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in done(granted) }
    }

    static var isAuthorized: (@escaping (Bool) -> Void) -> Void = { done in
        UNUserNotificationCenter.current().getNotificationSettings { done($0.authorizationStatus == .authorized) }
    }

    static func send(id: String, title: String, body: String, sound: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound ? .default : nil
        post(UNNotificationRequest(identifier: id, content: content, trigger: nil))
    }
}
