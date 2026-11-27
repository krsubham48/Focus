import FocusCore
import SwiftUI

struct DoneView: View {
    let model: FocusModel
    let record: SessionRecord

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
                Text("Done. You focused for \(FocusText.minutes(record.plannedMinutes)).")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Button {
                    model.acknowledgeCompletion()
                    try? model.start(minutes: record.plannedMinutes)
                } label: {
                    Text("Start another")
                        .font(.headline)
                        .foregroundStyle(Color(.systemBackground))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
                Button("Close") { model.acknowledgeCompletion() }
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("done-close")
            }
            .padding(24)
            .padding(.top, 80)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
