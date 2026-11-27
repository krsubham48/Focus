import FocusCore
import SwiftUI

/// Chooses the screen from the app's state, and keeps the clock moving.
struct RootView: View {
    let model: FocusModel

    var body: some View {
        content
            .task {
                while !Task.isCancelled {
                    model.tick()
                    try? await Task.sleep(for: .milliseconds(500))
                }
            }
    }

    @ViewBuilder private var content: some View {
        if !model.data.onboarded {
            OnboardingView(model: model)
        } else if model.session != nil {
            CountdownView(model: model)
        } else {
            MainTabView(model: model)
        }
    }
}
