import Foundation
import Testing
@testable import FocusCore

@MainActor final class FakeNotifier: Notifying {
    private(set) var pending: [Reminder] = []
    var nudgeDelays: [TimeInterval] { pending.filter { ReminderPlan.nudgeIDs.contains($0.id) }.map(\.delay) }
    func requestPermissionIfNeeded() async {}
    func schedule(_ reminders: [Reminder]) { cancel(ids: reminders.map(\.id)); pending += reminders }
    func cancel(ids: [String]) { pending.removeAll { ids.contains($0.id) } }
}
@MainActor final class FakeOpener: AppOpening {
    var openable: Set<String> = []
    private(set) var attempts: [String] = []
    func open(_ url: URL) async -> Bool { attempts.append(url.absoluteString); return openable.contains(url.absoluteString) }
}
@MainActor final class FakeActivity: ActivityPresenting {
    private(set) var shown: ActiveSession?
    func show(_ session: ActiveSession) { shown = session }
    func end() { shown = nil }
}
final class TestClock: @unchecked Sendable {
    var now = Date(timeIntervalSinceReferenceDate: 800_000_000)
    func advance(_ seconds: TimeInterval) { now += seconds }
}

@MainActor @Suite struct FocusModelTests {
    let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString)/focus.json")
    let clock = TestClock()
    let notifier = FakeNotifier()
    let opener = FakeOpener()
    let activity = FakeActivity()

    func makeModel() -> FocusModel {
        FocusModel(store: FocusStore(url: url), vault: PINVault(store: MemorySecretStore(), iterations: 10),
                   notifier: notifier, opener: opener, activity: activity, clock: { [clock] in clock.now })
    }

    @Test func startingSchedulesTheCompletionNoticeAndShowsTheActivity() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        #expect(notifier.pending.map(\.id) == ["focus.complete"])
        #expect(activity.shown == model.session && model.remaining == 1200)
    }

    @Test func startingTwiceKeepsOneSession() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        let first = model.session
        #expect(throws: SessionError.alreadyRunning) { try model.start(minutes: 5) }
        #expect(model.session == first && notifier.pending.count == 1)
    }

    @Test func leavingSchedulesReminders() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        model.enteredBackground(hasActiveCall: false)
        #expect(notifier.nudgeDelays == [20, 120, 420, 720, 1020])
    }

    @Test func leavingWithoutASessionSchedulesNothing() {
        makeModel().enteredBackground(hasActiveCall: false)
        #expect(notifier.pending.isEmpty)
    }

    @Test func leavingThroughAButtonStaysQuietUntilTheUserReturns() async throws {
        let model = makeModel()
        try model.start(minutes: 20)
        opener.openable = ["whatsapp://"]
        await model.open(.whatsApp)
        model.enteredBackground(hasActiveCall: false)
        #expect(notifier.nudgeDelays.isEmpty)
        model.becameActive()
        model.enteredBackground(hasActiveCall: false)
        #expect(!notifier.nudgeDelays.isEmpty)
    }

    @Test func failedOpenShowsAMessageAndStillRemindsOnNextExit() async throws {
        let model = makeModel()
        try model.start(minutes: 20)
        await model.open(.spotify)
        #expect(model.openFailureMessage == "Spotify isn't installed.")
        model.enteredBackground(hasActiveCall: false)
        #expect(!notifier.nudgeDelays.isEmpty)
    }

    @Test func safariTriesTheNextLink() async {
        let model = makeModel()
        opener.openable = ["https://www.google.com/"]
        await model.open(.safari)
        #expect(opener.attempts == ["x-web-search://?", "https://www.google.com/"])
        #expect(model.openFailureMessage == nil)
    }

    @Test func aCallKeepsItQuiet() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        model.enteredBackground(hasActiveCall: true)
        #expect(notifier.nudgeDelays.isEmpty)
    }

    @Test func lockingCancelsReminders() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        model.enteredBackground(hasActiveCall: false)
        model.deviceLocked()
        #expect(notifier.nudgeDelays.isEmpty && notifier.pending.map(\.id) == ["focus.complete"])
    }

    @Test func quittingEarlyCancelsEverything() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        model.enteredBackground(hasActiveCall: false)
        try model.quitEarly()
        #expect(notifier.pending.isEmpty && activity.shown == nil && model.session == nil)
        #expect(model.data.history.map(\.outcome) == [.quitEarly])
    }

    @Test func timeUpRecordsOneCompletion() throws {
        let model = makeModel()
        try model.start(minutes: 20)
        clock.advance(1201)
        model.tick(); model.tick()
        #expect(model.data.history.count == 1 && model.completedSession?.outcome == .completed)
        #expect(activity.shown == nil && notifier.nudgeDelays.isEmpty)
        model.acknowledgeCompletion()
        #expect(model.completedSession == nil)
    }

    @Test func aSessionThatEndedWhileClosedIsRecordedOnLaunch() throws {
        try makeModel().start(minutes: 1)
        clock.advance(3600)
        let relaunched = makeModel()
        #expect(relaunched.session == nil && relaunched.completedSession?.plannedMinutes == 1)
        #expect(makeModel().data.history.count == 1)
    }

    @Test func theGuardActsOnlyDuringASession() throws {
        let model = makeModel()
        #expect(!model.guardTriggered() && !model.showGuardBanner)
        try model.start(minutes: 20)
        #expect(model.guardTriggered() && model.showGuardBanner && model.data.lastGuardRun == clock.now)
        try model.quitEarly()
        #expect(!model.showGuardBanner)
    }
}
