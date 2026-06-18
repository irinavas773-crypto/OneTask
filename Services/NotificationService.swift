import Foundation
import UserNotifications

final class NotificationService {
    private let reminderID = "onetask.reminder"
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleReminder(title: String, after minutes: Int) {
        cancelReminders()
        guard minutes > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task still open"
        content.body = title
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminderID,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelReminders() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
    }
}
