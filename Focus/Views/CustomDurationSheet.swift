import FocusCore
import SwiftUI

/// Any length from one minute to two hours.
struct CustomDurationSheet: View {
    @Binding var minutes: Int
    @Environment(\.dismiss) private var dismiss
    @State private var hours: Int
    @State private var rest: Int

    init(minutes: Binding<Int>) {
        _minutes = minutes
        _hours = State(initialValue: minutes.wrappedValue / 60)
        _rest = State(initialValue: minutes.wrappedValue % 60)
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                Picker("Hours", selection: $hours) {
                    ForEach(0...2, id: \.self) { Text("\($0) h").tag($0) }
                }
                Picker("Minutes", selection: $rest) {
                    ForEach(0...59, id: \.self) { Text("\($0) min").tag($0) }
                }
            }
            .pickerStyle(.wheel)
            .padding(.horizontal)
            .navigationTitle("Up to 2 hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        minutes = SessionRules.minutes(hours: hours, minutes: rest)
                        dismiss()
                    }
                }
            }
        }
    }
}
