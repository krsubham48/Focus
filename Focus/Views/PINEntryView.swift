import FocusCore
import SwiftUI

/// Ten dots and a number pad. Hands over the PIN on the tenth digit.
struct PINEntryView: View {
    let title: String
    var message: String?
    let onComplete: (String) -> Void
    @State private var digits = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(message ?? " ")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 10) {
                    ForEach(0..<PINRules.length, id: \.self) { index in
                        Circle()
                            .fill(index < digits.count ? Color.accentColor : Color(.systemFill))
                            .frame(width: 14, height: 14)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("\(digits.count) of \(PINRules.length) digits entered")
                NumberPad(
                    onDigit: add,
                    onDelete: { if !digits.isEmpty { digits.removeLast() } })
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func add(_ digit: Int) {
        digits += String(digit)
        guard digits.count == PINRules.length else { return }
        let pin = digits
        digits = ""
        onComplete(pin)
    }
}
