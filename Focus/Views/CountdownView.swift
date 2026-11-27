import FocusCore
import SwiftUI

struct CountdownView: View {
    @Bindable var model: FocusModel

    private var fractionLeft: Double {
        guard let session = model.session else { return 0 }
        let total = session.endsAt.timeIntervalSince(session.startedAt)
        return total > 0 ? model.remaining / total : 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                }
                .frame(width: 260, height: 260)
                if let session = model.session {
                    Text("ends at \(session.endsAt.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                QuickAppGrid(model: model)
                Button("Override") {}
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("override")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
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
