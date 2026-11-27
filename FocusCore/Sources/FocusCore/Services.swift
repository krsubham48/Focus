import Foundation

/// The parts of iOS the model needs. The app supplies the real ones.
@MainActor public protocol Notifying: AnyObject {
    func requestPermissionIfNeeded() async
    /// A reminder with an id already pending replaces it.
    func schedule(_ reminders: [Reminder])
    func cancel(ids: [String])
}

@MainActor public protocol AppOpening: AnyObject {
    func open(_ url: URL) async -> Bool
}

@MainActor public protocol ActivityPresenting: AnyObject {
    /// Safe to call again for the same session.
    func show(_ session: ActiveSession)
    func end()
}
