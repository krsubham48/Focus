import Foundation

/// The words the app uses for times and counts.
public enum FocusText {
    /// Countdown digits: "18:42", or "1:59:59" from an hour up.
    public static func clock(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        let (hours, minutes, rest) = (total / 3600, total % 3600 / 60, total % 60)
        let two = { (value: Int) in value < 10 ? "0\(value)" : "\(value)" }
        return hours > 0 ? "\(hours):\(two(minutes)):\(two(rest))" : "\(minutes):\(two(rest))"
    }

    public static func minutes(_ count: Int) -> String {
        count == 1 ? "1 minute" : "\(count) minutes"
    }

    public static func shortDuration(_ minutes: Int) -> String {
        guard minutes >= 60 else { return "\(minutes) min" }
        let (hours, rest) = (minutes / 60, minutes % 60)
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
    }

    public static func sessions(_ count: Int) -> String {
        count == 1 ? "1 session" : "\(count) sessions"
    }

    /// Whole minutes still to go, never less than one.
    public static func minutesLeft(_ seconds: TimeInterval) -> Int {
        max(1, Int((seconds / 60).rounded(.up)))
    }
}
