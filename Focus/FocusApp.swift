import SwiftUI

@main
struct FocusApp: App {
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    private let model = AppEnvironment.model

    var body: some Scene {
        WindowGroup { RootView(model: model) }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    model.becameActive()
                case .background:
                    model.enteredBackground(hasActiveCall: AppEnvironment.watcher.hasActiveCall)
                    if model.session != nil {
                        AppEnvironment.watcher.watchForLock { model.deviceLocked() }
                    }
                default:
                    break
                }
            }
    }
}
