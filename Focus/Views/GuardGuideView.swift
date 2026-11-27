import FocusCore
import SwiftUI

/// How to set up the optional app guard in Apple's Shortcuts app.
struct GuardGuideView: View {
    let model: FocusModel
    /// Set when the guide is part of first launch.
    var onDone: (() -> Void)?
    @Environment(\.openURL) private var openURL

    private let steps = [
        "Open the Shortcuts app and tap Automation.",
        "Tap + and choose App.",
        "Choose the apps that distract you. Don't choose Phone, Messages, WhatsApp, Safari, Camera, Spotify or Focus.",
        "Keep Is Opened, choose Run Immediately and turn off Notify When Run.",
        "Tap New Blank Automation, add the action Focus Guard, then Done.",
    ]

    private var lastRun: String {
        model.data.lastGuardRun.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? "never"
    }

    var body: some View {
        List {
            Section {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1).").fontWeight(.semibold).monospacedDigit()
                        Text(step)
                    }
                }
            }
            Section {
                Text("To test: start a session and open one of those apps.")
                Text("Last ran: \(lastRun)")
                Button("Open Shortcuts") {
                    if let url = URL(string: "shortcuts://") { openURL(url) }
                }
            }
        }
        .navigationTitle("App guard")
        .toolbar {
            if let onDone {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
    }
}
