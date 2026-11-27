import CallKit
import UIKit

/// Tells a call or a screen lock apart from the user leaving. Public APIs only.
@MainActor
final class DeviceWatcher {
    private let calls = CXCallObserver()
    private var watch: Task<Void, Never>?
    private var lockSignalled = false

    var hasActiveCall: Bool { calls.calls.contains { !$0.hasEnded } }

    /// iOS reports a lock a few seconds late, so look for up to 15 seconds.
    /// The first reminder is due after that.
    func watchForLock(onLock: @escaping @MainActor () -> Void) {
        watch?.cancel()
        lockSignalled = false
        let observer = NotificationCenter.default.addObserver(
            forName: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.lockSignalled = true }
        }
        var background = UIBackgroundTaskIdentifier.invalid
        background = UIApplication.shared.beginBackgroundTask(withName: "lock-watch") {
            UIApplication.shared.endBackgroundTask(background)
        }
        watch = Task {
            for _ in 0..<15 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                if lockSignalled || !UIApplication.shared.isProtectedDataAvailable {
                    onLock()
                    break
                }
            }
            NotificationCenter.default.removeObserver(observer)
            UIApplication.shared.endBackgroundTask(background)
        }
    }
}
