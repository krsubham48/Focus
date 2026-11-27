import Foundation
import Observation

/// The app's state and what happens to it. Screens read it and call it.
@MainActor
@Observable
public final class FocusModel {
    public private(set) var data: FocusData
    public private(set) var now: Date
    public var showGuardBanner = false
    public var openFailureMessage: String?
    public let vault: PINVault

    @ObservationIgnored private var leavingForQuickApp = false
    @ObservationIgnored private let store: FocusStore
    @ObservationIgnored private let notifier: any Notifying
    @ObservationIgnored private let opener: any AppOpening
    @ObservationIgnored private let activity: any ActivityPresenting
    @ObservationIgnored private let secondsPerMinute: TimeInterval
    @ObservationIgnored private let clock: @Sendable () -> Date

    public init(
        store: FocusStore, vault: PINVault, notifier: any Notifying, opener: any AppOpening,
        activity: any ActivityPresenting, secondsPerMinute: TimeInterval = 60,
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.store = store
        self.vault = vault
        self.notifier = notifier
        self.opener = opener
        self.activity = activity
        self.secondsPerMinute = secondsPerMinute
        self.clock = clock
        data = store.load()
        now = clock()
        // A session may have ended while the app was closed.
        if data.settle(now: now) != nil { sessionCompleted() }
    }

    public var session: ActiveSession? { data.active }

    public var remaining: TimeInterval {
        data.active.map { max(0, $0.endsAt.timeIntervalSince(now)) } ?? 0
    }

    /// The completed session still waiting for its "Done" screen.
    public var completedSession: SessionRecord? {
        data.unseenCompletion.flatMap { id in data.history.last { $0.id == id } }
    }

    public func requestReminderPermission() async {
        await notifier.requestPermissionIfNeeded()
    }

    public func start(minutes: Int) throws {
        tick()
        let session = try data.start(minutes: minutes, now: now, secondsPerMinute: secondsPerMinute)
        leavingForQuickApp = false
        save()
        notifier.cancel(ids: ReminderPlan.nudgeIDs + [ReminderPlan.completionID])
        notifier.schedule([ReminderPlan.completion(minutes: minutes, delay: session.endsAt.timeIntervalSince(now))])
        activity.show(session)
    }

    public func tick() {
        now = clock()
        // Only assign when a session actually ends, so screens are not redrawn for nothing.
        guard let session = data.active, now >= session.endsAt else { return }
        data.settle(now: now)
        sessionCompleted()
    }

    public func quitEarly() throws {
        now = clock()
        let record = try data.quitEarly(now: now)
        guard record.outcome == .quitEarly else { return sessionCompleted() }
        save()
        notifier.cancel(ids: ReminderPlan.nudgeIDs + [ReminderPlan.completionID])
        activity.end()
        showGuardBanner = false
    }

    public func becameActive() {
        tick()
        leavingForQuickApp = false
        notifier.cancel(ids: ReminderPlan.nudgeIDs)
        if let session { activity.show(session) } else { activity.end() }
    }

    public func enteredBackground(hasActiveCall: Bool) {
        tick()
        guard session != nil else { return }
        let departure: Departure = leavingForQuickApp ? .quickApp : hasActiveCall ? .activeCall : .elsewhere
        let nudges = ReminderPlan.nudges(leaving: departure, remaining: remaining)
        if !nudges.isEmpty { notifier.schedule(nudges) }
    }

    public func deviceLocked() {
        notifier.cancel(ids: ReminderPlan.nudgeIDs)
    }

    public func open(_ app: QuickApp) async {
        // Set before the first await: iOS can background the app during the open.
        leavingForQuickApp = true
        openFailureMessage = nil
        for url in app.urls {
            if await opener.open(url) { return }
        }
        leavingForQuickApp = false
        openFailureMessage = app.failureMessage
    }

    @discardableResult
    public func guardTriggered() -> Bool {
        tick()
        data.lastGuardRun = now
        save()
        guard session != nil else { return false }
        showGuardBanner = true
        return true
    }

    public func finishOnboarding() {
        data.onboarded = true
        save()
    }

    public func acknowledgeCompletion() {
        data.unseenCompletion = nil
        save()
    }

    /// The completion notice stays scheduled: it is how the user hears the time is up.
    private func sessionCompleted() {
        save()
        notifier.cancel(ids: ReminderPlan.nudgeIDs)
        activity.end()
        showGuardBanner = false
    }

    private func save() {
        try? store.save(data)
    }
}
