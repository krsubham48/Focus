import FocusCore
import UserNotifications

/// Reminders as local notifications.
final class UserNotifier: Notifying {
    private var center: UNUserNotificationCenter { .current() }

    func requestPermissionIfNeeded() async {
        guard await center.notificationSettings().authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    /// Adds without awaiting, so a later `cancel` cannot overtake it.
    func schedule(_ reminders: [Reminder]) {
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, reminder.delay), repeats: false)
            center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }

    func cancel(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
}
