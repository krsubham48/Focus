// SessionEngineTests.swift
import Foundation
import Testing
@testable import FocusCore

@Suite struct SessionEngineTests {
    let t0 = Date(timeIntervalSinceReferenceDate: 800_000_000)

    @Test func startsASessionEndingAfterThePlannedMinutes() throws {
        var data = FocusData()
        let session = try data.start(minutes: 20, now: t0)
        #expect(session.endsAt == t0.addingTimeInterval(1200))
        #expect(data.active == session && data.lastMinutes == 20)
    }

    @Test(arguments: [0, 121, -5]) func startRejectsLengthsOutsideTheLimits(minutes: Int) {
        var data = FocusData()
        #expect(throws: SessionError.invalidDuration) { try data.start(minutes: minutes, now: t0) }
    }

    @Test func startWhileRunningThrows() throws {
        var data = FocusData()
        _ = try data.start(minutes: 20, now: t0)
        #expect(throws: SessionError.alreadyRunning) { try data.start(minutes: 5, now: t0.addingTimeInterval(10)) }
    }

    @Test func startAfterAnExpiredSessionSettlesItFirst() throws {
        var data = FocusData()
        _ = try data.start(minutes: 1, now: t0)
        _ = try data.start(minutes: 5, now: t0.addingTimeInterval(600))
        #expect(data.history.map(\.outcome) == [.completed])
        #expect(data.active?.plannedMinutes == 5 && data.unseenCompletion == nil)
    }

    @Test func settleRecordsCompletionOnlyAfterTheEndAndOnlyOnce() throws {
        var data = FocusData()
        let session = try data.start(minutes: 20, now: t0)
        #expect(data.settle(now: t0.addingTimeInterval(1199)) == nil)
        let record = data.settle(now: t0.addingTimeInterval(5000))
        #expect(record?.outcome == .completed && record?.endedAt == session.endsAt)
        #expect(data.unseenCompletion == record?.id && data.active == nil)
        #expect(data.settle(now: t0.addingTimeInterval(6000)) == nil)
        #expect(data.history.count == 1)
    }

    @Test func quitEarlyRecordsAFailedSession() throws {
        var data = FocusData()
        _ = try data.start(minutes: 20, now: t0)
        let record = try data.quitEarly(now: t0.addingTimeInterval(300))
        #expect(record.outcome == .quitEarly && record.endedAt == t0.addingTimeInterval(300))
        #expect(data.active == nil && data.unseenCompletion == nil)
    }

    @Test func quitEarlyAfterEndRecordsCompletion() throws {
        var data = FocusData()
        _ = try data.start(minutes: 1, now: t0)
        #expect(try data.quitEarly(now: t0.addingTimeInterval(61)).outcome == .completed)
        #expect(data.history.count == 1)
    }

    @Test func quitEarlyWithoutASessionThrows() {
        var data = FocusData()
        #expect(throws: SessionError.noActiveSession) { try data.quitEarly(now: t0) }
    }

    @Test func scaledMinutesShortenTheSessionButKeepThePlan() throws {
        var data = FocusData()
        let session = try data.start(minutes: 20, now: t0, secondsPerMinute: 3)
        #expect(session.endsAt == t0.addingTimeInterval(60) && session.plannedMinutes == 20)
    }
}
