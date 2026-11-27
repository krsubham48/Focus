import FocusCore
import SwiftUI

/// The deliberately slow way out: PIN, five sums, "are you sure", PIN again.
struct OverrideView: View {
    let model: FocusModel
    @Environment(\.dismiss) private var dismiss
    @State private var flow = OverrideFlow()
    @State private var typed = ""
    @State private var message: String?

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .accessibilityIdentifier("override-cancel")
                    }
                }
        }
        // Time ran out while the user was in here: the session counts as completed.
        .onChange(of: model.session == nil) { _, ended in
            if ended { dismiss() }
        }
    }

    @ViewBuilder private var content: some View {
        switch flow.step {
        case .enterPIN:
            PINEntryView(title: "Enter your PIN", message: message, onComplete: check)
                .id("first")
        case let .sum(sum, solved):
            sumView(sum, solved: solved)
        case .confirm:
            confirmView
        case .reenterPIN:
            PINEntryView(title: "Enter your PIN again to end", message: message, onComplete: check)
                .id("again")
        case .approved:
            Color.clear
        }
    }

    private func sumView(_ sum: Sum, solved: Int) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Question \(solved + 1) of \(OverrideFlow.sumsRequired)")
                    .foregroundStyle(.secondary)
                Text(sum.text)
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .accessibilityIdentifier("sum-text")
                Text(typed.isEmpty ? " " : typed)
                    .font(.system(.title, design: .rounded))
                    .monospacedDigit()
                    .frame(minWidth: 100)
                    .overlay(alignment: .bottom) { Divider() }
                    .accessibilityLabel("Your answer: \(typed)")
                Text(message ?? " ").foregroundStyle(.secondary)
                NumberPad(
                    onDigit: { if typed.count < 3 { typed += String($0) } },
                    onDelete: { if !typed.isEmpty { typed.removeLast() } },
                    onEnter: submitAnswer)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var confirmView: some View {
        VStack(spacing: 16) {
            Text("Are you sure? \(FocusText.minutes(FocusText.minutesLeft(model.remaining))) left.")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            Button {
                dismiss()
            } label: {
                Text("Keep focusing")
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("confirm-keep")
            Button("Yes", role: .destructive) {
                message = nil
                flow.confirm()
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier("confirm-yes")
        }
        .padding(24)
    }

    private func check(_ pin: String) {
        let correct = model.vault.matches(pin)
        message = correct ? nil : "That PIN isn't right."
        var generator = SystemRandomNumberGenerator()
        flow.pinEntered(correct: correct, using: &generator)
        if flow.step == .approved {
            try? model.quitEarly()
            dismiss()
        }
    }

    private func submitAnswer() {
        guard let value = Int(typed) else { return }
        typed = ""
        var generator = SystemRandomNumberGenerator()
        let correct = flow.answer(value, using: &generator)
        message = correct ? nil : "Not quite. Try this one."
    }
}
