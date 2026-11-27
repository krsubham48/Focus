import ActivityKit
import FocusCore
import Foundation

/// The countdown on the Lock Screen and in the Dynamic Island. Best effort: failures are ignored.
final class LiveActivityController: ActivityPresenting {
    func show(_ session: ActiveSession) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let running = Activity<FocusActivityAttributes>.activities
        if running.contains(where: { $0.attributes.startedAt == session.startedAt }) { return }
        end()
        let content = ActivityContent(
            state: FocusActivityAttributes.ContentState(endsAt: session.endsAt), staleDate: session.endsAt)
        _ = try? Activity.request(
            attributes: FocusActivityAttributes(startedAt: session.startedAt), content: content, pushType: nil)
    }

    /// Ends only what exists now, so it cannot end an activity requested afterwards.
    func end() {
        let ids = Set(Activity<FocusActivityAttributes>.activities.map(\.id))
        guard !ids.isEmpty else { return }
        Task {
            for activity in Activity<FocusActivityAttributes>.activities where ids.contains(activity.id) {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
