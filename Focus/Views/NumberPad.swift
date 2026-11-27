import SwiftUI

/// Digits for the PIN and the sums.
struct NumberPad: View {
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    var onEnter: (() -> Void)?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...9, id: \.self) { digit($0) }
            key("key-delete", label: "Delete", action: onDelete) {
                Image(systemName: "delete.left")
            }
            digit(0)
            if let onEnter {
                key("key-enter", label: "Enter", action: onEnter) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                }
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: 320)
    }

    private func digit(_ value: Int) -> some View {
        key("key-\(value)", label: "\(value)", action: { onDigit(value) }) { Text("\(value)") }
    }

    private func key(
        _ id: String, label: String, action: @escaping () -> Void, @ViewBuilder content: () -> some View
    ) -> some View {
        Button(action: action) {
            content()
                .font(.title.weight(.medium))
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(id)
    }
}
