import Foundation

/// The one session that is running now.
public struct ActiveSession: Codable, Equatable, Sendable {
    public let id: UUID
    public let startedAt: Date
    public let endsAt: Date
    public let plannedMinutes: Int

    public init(id: UUID, startedAt: Date, endsAt: Date, plannedMinutes: Int) {
        self.id = id
        self.startedAt = startedAt
        self.endsAt = endsAt
        self.plannedMinutes = plannedMinutes
    }
}

public enum SessionOutcome: String, Codable, Sendable {
    case completed, quitEarly
}

/// A finished session, kept for the history.
public struct SessionRecord: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let startedAt: Date
    public let endedAt: Date
    public let plannedMinutes: Int
    public let outcome: SessionOutcome

    public init(id: UUID, startedAt: Date, endedAt: Date, plannedMinutes: Int, outcome: SessionOutcome) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.outcome = outcome
    }
}

/// Everything the app saves, apart from the PIN.
public struct FocusData: Codable, Equatable, Sendable {
    public var active: ActiveSession?
    public var history: [SessionRecord] = []
    public var lastMinutes = 20
    public var onboarded = false
    public var lastGuardRun: Date?
    /// A completed session whose "Done" screen has not been shown yet.
    public var unseenCompletion: UUID?

    public init() {}

    /// Every field is optional in the file, so a newer build keeps older data.
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        active = try values.decodeIfPresent(ActiveSession.self, forKey: .active)
        history = try values.decodeIfPresent([SessionRecord].self, forKey: .history) ?? []
        lastMinutes = try values.decodeIfPresent(Int.self, forKey: .lastMinutes) ?? 20
        onboarded = try values.decodeIfPresent(Bool.self, forKey: .onboarded) ?? false
        lastGuardRun = try values.decodeIfPresent(Date.self, forKey: .lastGuardRun)
        unseenCompletion = try values.decodeIfPresent(UUID.self, forKey: .unseenCompletion)
    }
}
