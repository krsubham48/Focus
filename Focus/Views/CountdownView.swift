import FocusCore
import SwiftUI

struct CountdownView: View {
    @Bindable var model: FocusModel
    @State private var showingOverride = false

    private var fractionLeft: Double {
        guard let session = model.session else { return 0 }
        let total = session.endsAt.timeIntervalSince(session.startedAt)
        return total > 0 ? model.remaining / total : 0
    }

    private var spokenRemaining: String {
        let seconds = Int(model.remaining.rounded(.up))
        return "\(FocusText.minutes(seconds / 60)) \(seconds % 60) seconds remaining"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if model.showGuardBanner {
                    Button {
                        model.showGuardBanner = false
                    } label: {
                        Text("Stay with it. \(FocusText.minutes(FocusText.minutesLeft(model.remaining))) left.")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal)
                            .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Hides this message")
                }
                Text("Stay focused").font(.title2.weight(.semibold))
                ZStack {
                    ProgressRing(fraction: fractionLeft)
                    Text(FocusText.clock(model.remaining))
                        .font(.system(size: 56, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(28)
                        .accessibilityIdentifier("countdown-time")
                        .accessibilityLabel(spokenRemaining)
                }
                .frame(width: 260, height: 260)
                if let session = model.session {
                    Text("ends at \(session.endsAt.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                QuickAppGrid(model: model)
                Button("Override") { showingOverride = true }
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("override")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .fullScreenCover(isPresented: $showingOverride) {
            OverrideView(model: model)
        }
        .alert(
            model.openFailureMessage ?? "",
            isPresented: Binding(
                get: { model.openFailureMessage != nil },
                set: { if !$0 { model.openFailureMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        }
    }
}
