import FocusCore
import SwiftUI

struct MainTabView: View {
    let model: FocusModel
    @State private var tab = AppEnvironment.initialTab

    var body: some View {
        TabView(selection: $tab) {
            Tab("Focus", systemImage: "timer", value: AppTab.focus) {
                HomeView(model: model)
            }
            Tab("Stats", systemImage: "chart.bar.fill", value: AppTab.stats) {
                StatsView(model: model)
            }
            Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView(model: model)
            }
        }
    }
}
