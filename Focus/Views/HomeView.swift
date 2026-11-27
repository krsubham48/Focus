import FocusCore
import SwiftUI

struct HomeView: View {
    let model: FocusModel
    @State private var minutes: Int
    @State private var choosingCustom = false

    init(model: FocusModel) {
        self.model = model
        _minutes = State(initialValue: model.data.lastMinutes)
    }

    private var isCustom: Bool { !SessionRules.presets.contains(minutes) }

    private var startTitle: String {
        "Start " + (minutes < 60 ? FocusText.minutes(minutes) : FocusText.shortDuration(minutes))
    }

    private var todayText: String {
        let today = Stats.day(.now, history: model.data.history, calendar: .current)
        guard today.completed > 0 else { return "Today: no sessions yet" }
        return "Today: \(FocusText.sessions(today.completed)) · \(FocusText.shortDuration(today.focusMinutes))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How long?").font(.title3.weight(.medium))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 12)], spacing: 12) {
                        ForEach(SessionRules.presets, id: \.self) { preset in
                            LengthButton(title: SessionRules.presetLabel(preset), selected: minutes == preset) {
                                minutes = preset
                            }
                            .accessibilityIdentifier("preset-\(preset)")
                        }
                        LengthButton(
                            title: isCustom ? FocusText.shortDuration(minutes) : "Custom", selected: isCustom
                        ) {
                            choosingCustom = true
                        }
                        .accessibilityIdentifier("preset-custom")
                    }
                    Button {
                        Task {
                            await model.requestReminderPermission()
                            try? model.start(minutes: minutes)
                        }
                    } label: {
                        Text(startTitle)
                            .font(.headline)
                            .foregroundStyle(Color(.systemBackground))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("start")
                    .padding(.top, 12)
                    Text(todayText)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationTitle("Focus")
            .sheet(isPresented: $choosingCustom) {
                CustomDurationSheet(minutes: $minutes)
                    .presentationDetents([.medium])
            }
        }
    }
}

private struct LengthButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(selected ? Color(.systemBackground) : Color.primary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    selected ? Color.accentColor : Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
