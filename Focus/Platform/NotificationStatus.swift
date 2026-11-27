import UserNotifications

enum NotificationStatus {
    static func current() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
}
