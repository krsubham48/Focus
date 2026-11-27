// ReminderPlanTests.swift
import Testing
@testable import FocusCore

@Suite struct ReminderPlanTests {
    @Test func remindsAfterTwentySecondsTwoMinutesThenEveryFive() {
        let nudges = ReminderPlan.nudges(leaving: .elsewhere, remaining: 1200)
        #expect(nudges.map(\.delay) == [20, 120, 420, 720, 1020])
        #expect(nudges.map(\.id) == Array(ReminderPlan.nudgeIDs.prefix(5)))
        #expect(nudges.first?.title == "Focus")
        #expect(nudges.first?.body == "20 minutes left. Come back to Focus.")
        #expect(nudges.last?.body == "3 minutes left. Come back to Focus.")
    }

    @Test(arguments: [Departure.quickApp, .activeCall]) func staysQuiet(departure: Departure) {
        #expect(ReminderPlan.nudges(leaving: departure, remaining: 1200).isEmpty)
    }

    @Test func lastMinuteIsSingular() {
        #expect(ReminderPlan.nudges(leaving: .elsewhere, remaining: 80).map(\.body) == ["1 minute left. Come back to Focus."])
    }

    @Test func nothingAtOrAfterTheEnd() {
        #expect(ReminderPlan.nudges(leaving: .elsewhere, remaining: 20).isEmpty)
    }

    @Test func twoHoursStaysWithinTheCancellableIDs() {
        let nudges = ReminderPlan.nudges(leaving: .elsewhere, remaining: 7200)
        #expect(nudges.count == 25)
        #expect(Set(nudges.map(\.id)).isSubset(of: Set(ReminderPlan.nudgeIDs)))
    }

    @Test func completionNotice() {
        let notice = ReminderPlan.completion(minutes: 20, delay: 1200)
        #expect(notice == Reminder(id: "focus.complete", delay: 1200, title: "Focus complete", body: "You focused for 20 minutes."))
    }
}
