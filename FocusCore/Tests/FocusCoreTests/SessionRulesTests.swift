// SessionRulesTests.swift
import Testing
@testable import FocusCore

@Suite struct SessionRulesTests {
    @Test func presetsMatchTheSpec() {
        #expect(SessionRules.presets == [1, 5, 10, 20, 30, 60])
        #expect(SessionRules.presets.map(SessionRules.presetLabel) == ["1m", "5m", "10m", "20m", "30m", "1h"])
    }

    @Test func customLengthIsClamped() {
        #expect(SessionRules.minutes(hours: 0, minutes: 0) == 1)
        #expect(SessionRules.minutes(hours: 2, minutes: 59) == 120)
        #expect(SessionRules.minutes(hours: 1, minutes: 15) == 75)
    }
}
