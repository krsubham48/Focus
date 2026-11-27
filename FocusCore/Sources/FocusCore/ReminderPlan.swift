import Foundation

/// How the app left the screen, which decides whether to remind.
public enum Departure: Equatable, Sendable {
    case quickApp, activeCall, elsewhere
}

public struct Reminder: Equatable, Sendable {
    public let id: String
    /// Seconds from now.
    public let delay: TimeInterval
    public let title: String
    public let body: String

    public init(id: String, delay: TimeInterval, title: String, body: String) {
        self.id = id
        self.delay = delay
        self.title = title
        self.body = body
    }
}

public enum ReminderPlan {
    public static let completionID = "focus.complete"
    /// Enough for a two-hour session, so all can be cancelled by name.
    public static let nudgeIDs = (0..<30).map { "focus.nudge.\($0)" }

    private static let firstDelay: TimeInterval = 20
    private static let secondDelay: TimeInterval = 120
    private static let repeatInterval: TimeInterval = 300

    /// Reminders after about 20 s, 2 min, then every 5 min, until the session ends.
    public static func nudges(leaving departure: Departure, remaining: TimeInterval) -> [Reminder] {
        guard departure == .elsewhere else { return [] }
        let repeats = stride(from: secondDelay + repeatInterval, to: remaining, by: repeatInterval)
        let delays = ([firstDelay, secondDelay] + repeats).filter { $0 < remaining }
        return zip(nudgeIDs, delays).map { id, delay in
            let left = FocusText.minutes(FocusText.minutesLeft(remaining - delay))
            return Reminder(id: id, delay: delay, title: "Focus", body: "\(left) left. Come back to Focus.")
        }
    }

    public static func completion(minutes: Int, delay: TimeInterval) -> Reminder {
        Reminder(
            id: completionID, delay: delay, title: "Focus complete",
            body: "You focused for \(FocusText.minutes(minutes)).")
    }
}
