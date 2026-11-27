import Foundation
import Testing
@testable import FocusCore

@Suite struct StatsTests {
    static func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        calendar.firstWeekday = 2
        return calendar
    }
    let tokyo = StatsTests.calendar("Asia/Tokyo")

    func date(_ text: String) -> Date { try! Date(text, strategy: .iso8601) }
    func record(_ start: String, _ minutes: Int, _ outcome: SessionOutcome = .completed) -> SessionRecord {
        SessionRecord(id: UUID(), startedAt: date(start), endedAt: date(start).addingTimeInterval(Double(minutes) * 60),
                      plannedMinutes: minutes, outcome: outcome)
    }

    @Test func countsCompletedAndQuitSeparately() {
        let history = [record("2026-11-26T09:00:00+09:00", 10), record("2026-11-26T11:00:00+09:00", 20),
                       record("2026-11-26T13:00:00+09:00", 60, .quitEarly)]
        let day = Stats.day(date("2026-11-26T18:00:00+09:00"), history: history, calendar: tokyo)
        #expect(day.completed == 2 && day.focusMinutes == 30 && day.quitEarly == 1)
    }

    @Test func aSessionBelongsToTheDayItStarted() {
        let history = [record("2026-11-25T23:50:00+09:00", 30)]
        #expect(Stats.day(date("2026-11-25T12:00:00+09:00"), history: history, calendar: tokyo).completed == 1)
        #expect(Stats.day(date("2026-11-26T12:00:00+09:00"), history: history, calendar: tokyo).completed == 0)
    }

    @Test func weekIsSevenDaysFromTheFirstWeekday() {
        let history = [record("2026-11-23T08:00:00+09:00", 10), record("2026-11-29T22:00:00+09:00", 5),
                       record("2026-11-30T08:00:00+09:00", 20)]
        let week = Stats.week(containing: date("2026-11-26T12:00:00+09:00"), history: history, calendar: tokyo)
        #expect(week.days.count == 7 && week.days.first?.day == date("2026-11-23T00:00:00+09:00"))
        #expect(week.completed == 2 && week.focusMinutes == 15)
    }

    @Test func groupingFollowsTheTimeZoneInUse() {
        let history = [record("2026-11-25T20:00:00Z", 10)]
        #expect(Stats.day(date("2026-11-26T12:00:00+09:00"), history: history, calendar: tokyo).completed == 1)
        #expect(Stats.day(date("2026-11-25T12:00:00Z"), history: history, calendar: Self.calendar("UTC")).completed == 1)
    }
}
