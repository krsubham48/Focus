#if os(iOS)
import ActivityKit
import Foundation

/// What the app hands to the Lock Screen and Dynamic Island countdown.
public struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var endsAt: Date
        public init(endsAt: Date) { self.endsAt = endsAt }
    }

    public var startedAt: Date
    public init(startedAt: Date) { self.startedAt = startedAt }
}
#endif
