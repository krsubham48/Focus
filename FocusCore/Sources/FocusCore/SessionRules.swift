public enum SessionRules {
    public static let presets = [1, 5, 10, 20, 30, 60]
    public static let allowedMinutes = 1...120

    /// A custom length, brought inside the limits.
    public static func minutes(hours: Int, minutes: Int) -> Int {
        min(max(hours * 60 + minutes, allowedMinutes.lowerBound), allowedMinutes.upperBound)
    }

    public static func presetLabel(_ minutes: Int) -> String {
        minutes % 60 == 0 ? "\(minutes / 60)h" : "\(minutes)m"
    }
}
