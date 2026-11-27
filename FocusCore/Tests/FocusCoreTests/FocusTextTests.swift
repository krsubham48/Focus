// FocusTextTests.swift
import Testing
@testable import FocusCore

@Suite struct FocusTextTests {
    @Test func clock() {
        #expect([1122, 7, 0.4, 3600, 7199].map(FocusText.clock) == ["18:42", "0:07", "0:01", "1:00:00", "1:59:59"])
    }

    @Test func words() {
        #expect([0, 45, 60, 70].map(FocusText.shortDuration) == ["0 min", "45 min", "1 h", "1 h 10 min"])
        #expect(FocusText.minutes(1) == "1 minute" && FocusText.minutes(20) == "20 minutes")
        #expect(FocusText.sessions(1) == "1 session" && FocusText.sessions(9) == "9 sessions")
        #expect(FocusText.minutesLeft(1180) == 20 && FocusText.minutesLeft(0) == 1)
    }
}
