import Foundation

public enum SessionError: Error, Equatable {
    case alreadyRunning, noActiveSession, invalidDuration
}

extension FocusData {
    @discardableResult
    public mutating func start(minutes: Int, now: Date, secondsPerMinute: TimeInterval = 60) throws -> ActiveSession {
        guard SessionRules.allowedMinutes.contains(minutes) else { throw SessionError.invalidDuration }
        settle(now: now)
        guard active == nil else { throw SessionError.alreadyRunning }
        let session = ActiveSession(
            id: UUID(), startedAt: now,
            endsAt: now.addingTimeInterval(Double(minutes) * secondsPerMinute),
            plannedMinutes: minutes)
        active = session
        lastMinutes = minutes
        unseenCompletion = nil
        return session
    }

    /// Records the running session as completed once its end time has passed.
    @discardableResult
    public mutating func settle(now: Date) -> SessionRecord? {
        guard let session = active, now >= session.endsAt else { return nil }
        let record = finish(session, at: session.endsAt, outcome: .completed)
        unseenCompletion = record.id
        return record
    }

    /// Ends the session as failed, unless its time already ran out.
    public mutating func quitEarly(now: Date) throws -> SessionRecord {
        if let completed = settle(now: now) { return completed }
        guard let session = active else { throw SessionError.noActiveSession }
        return finish(session, at: now, outcome: .quitEarly)
    }

    private mutating func finish(_ session: ActiveSession, at end: Date, outcome: SessionOutcome) -> SessionRecord {
        let record = SessionRecord(
            id: session.id, startedAt: session.startedAt, endedAt: end,
            plannedMinutes: session.plannedMinutes, outcome: outcome)
        history.append(record)
        active = nil
        return record
    }
}
