import FocusCore
import SwiftUI

/// A new PIN, entered twice. Asks for the current one unless the phone owner has just been confirmed.
struct ChangePINView: View {
    let model: FocusModel
    let requireCurrent: Bool
    @Environment(\.dismiss) private var dismiss

    private enum Step: Equatable {
        case current, new, confirm(String)
    }

    @State private var step: Step
    @State private var message: String?

    init(model: FocusModel, requireCurrent: Bool) {
        self.model = model
        self.requireCurrent = requireCurrent
        _step = State(initialValue: requireCurrent ? .current : .new)
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case .current:
            PINEntryView(title: "Enter your current PIN", message: message) { pin in
                if model.vault.matches(pin) {
                    message = nil
                    step = .new
                } else {
                    message = "That PIN isn't right."
                }
            }
            .id("current")
        case .new:
            PINEntryView(title: "Enter a new 10-digit PIN", message: message) { step = .confirm($0) }
                .id("new")
        case .confirm(let first):
            PINEntryView(title: "Enter it again") { second in
                if second == first, (try? model.vault.set(second)) != nil {
                    dismiss()
                } else {
                    message = "Those didn't match. Try again."
                    step = .new
                }
            }
            .id("confirm")
        }
    }
}
