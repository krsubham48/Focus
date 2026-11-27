import Foundation

public struct DayStats: Equatable, Identifiable, Sendable {
    /// Start of the day.
    public let day: Date
    public let completed: Int
    public let focusMinutes: Int
    public let quitEarly: Int

    public var id: Date { day }
}

public struct WeekStats: Equatable, Sendable {
    /// Seven days, oldest first.
    public let days: [DayStats]

    public var completed: Int { days.reduce(0) { $0 + $1.completed } }
    public var focusMinutes: Int { days.reduce(0) { $0 + $1.focusMinutes } }
}

/// Only completed sessions count as focus. A session belongs to the day it started.
public enum Stats {
    public static func day(_ date: Date, history: [SessionRecord], calendar: Calendar) -> DayStats {
        let records = history.filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
        let completed = records.filter { $0.outcome == .completed }
        return DayStats(
            day: calendar.startOfDay(for: date),
            completed: completed.count,
            focusMinutes: completed.reduce(0) { $0 + $1.plannedMinutes },
            quitEarly: records.count - completed.count)
    }

    public static func week(containing date: Date, history: [SessionRecord], calendar: Calendar) -> WeekStats {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        return WeekStats(days: days.map { day($0, history: history, calendar: calendar) })
    }
}
