import ActivityKit
import FocusCore
import SwiftUI
import WidgetKit

@main
struct FocusWidgetBundle: WidgetBundle {
    var body: some Widget { FocusLiveActivity() }
}

struct FocusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { _ in
            Text("Focus").padding()
        } dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) { Text("Focus") }
            } compactLeading: {
                Image(systemName: "hourglass")
            } compactTrailing: {
                Text("")
            } minimal: {
                Image(systemName: "hourglass")
            }
        }
    }
}
