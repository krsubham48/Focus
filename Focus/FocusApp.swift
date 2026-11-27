import SwiftUI

@main
struct FocusApp: App {
    var body: some Scene {
        WindowGroup { RootView(model: AppEnvironment.model) }
    }
}
