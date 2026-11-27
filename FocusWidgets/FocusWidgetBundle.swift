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
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            HStack {
                Label("Stay focused", systemImage: "hourglass")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                Spacer()
                Countdown(context: context)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120, alignment: .trailing)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text("Stay focused").font(.footnote)
                        Countdown(context: context)
                            .font(.system(.title, design: .rounded).weight(.semibold))
                            .multilineTextAlignment(.center)
                    }
                }
            } compactLeading: {
                Image(systemName: "hourglass").foregroundStyle(Color.accentColor)
            } compactTrailing: {
                Countdown(context: context).frame(width: 48)
            } minimal: {
                Image(systemName: "hourglass").foregroundStyle(Color.accentColor)
            }
        }
    }
}

/// Counts down by itself, and reads "Done" once the end time has passed.
private struct Countdown: View {
    let context: ActivityViewContext<FocusActivityAttributes>

    var body: some View {
        if context.isStale {
            Text("Done")
        } else {
            Text(timerInterval: context.attributes.startedAt...context.state.endsAt, countsDown: true)
                .monospacedDigit()
        }
    }
}
