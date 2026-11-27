import FocusCore
import Foundation

/// Does nothing. Stands in for iOS services in UI tests.
final class SilentPlatform: Notifying, AppOpening, ActivityPresenting {
    func requestPermissionIfNeeded() async {}
    func schedule(_ reminders: [Reminder]) {}
    func cancel(ids: [String]) {}
    func open(_ url: URL) async -> Bool { true }
    func show(_ session: ActiveSession) {}
    func end() {}
}
