import UserNotifications

enum Notifier {
    // Swapped out in tests: UNUserNotificationCenter throws when the process has no app bundle.
    static var post: (UNNotificationRequest) -> Void = { UNUserNotificationCenter.current().add($0) }

    static func send(id: String, title: String, body: String, sound: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound ? .default : nil
        post(UNNotificationRequest(identifier: id, content: content, trigger: nil))
    }
}
