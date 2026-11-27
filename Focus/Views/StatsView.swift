import Charts
import FocusCore
import SwiftUI

/// One week at a time: minutes focused per day, then the same in words.
struct StatsView: View {
    let model: FocusModel
    @State private var anchor = Date.now
    @State private var selected: Date?

    private var calendar: Calendar { .current }
    private var week: WeekStats { Stats.week(containing: anchor, history: model.data.history, calendar: calendar) }

    var body: some View {
        let week = week
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        header(week)
                        Text("\(FocusText.shortDuration(week.focusMinutes)) · \(FocusText.sessions(week.completed))")
                            .font(.title2.weight(.semibold))
                            .accessibilityIdentifier("stats-total")
                        Text(selectedText(week))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        chart(week)
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    let active = week.days.filter { $0.completed + $0.quitEarly > 0 }.reversed()
                    if active.isEmpty {
                        Text("No sessions this week.").foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(active)) { row($0) }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }

    private func header(_ week: WeekStats) -> some View {
        HStack {
            Button("Previous week", systemImage: "chevron.left") { move(by: -1) }
                .frame(minWidth: 44, minHeight: 44)
            Spacer()
            Text(title(week)).font(.headline)
            Spacer()
            Button("Next week", systemImage: "chevron.right") { move(by: 1) }
                .frame(minWidth: 44, minHeight: 44)
                .disabled(calendar.isDate(anchor, equalTo: .now, toGranularity: .weekOfYear))
        }
        .labelStyle(.iconOnly)
        // Borderless, so each arrow takes its own taps inside a list row.
        .buttonStyle(.borderless)
    }

    private func chart(_ week: WeekStats) -> some View {
        Chart(week.days) { day in
            BarMark(x: .value("Day", day.day, unit: .day), y: .value("Minutes", day.focusMinutes))
                .foregroundStyle(Color.accentColor)
                .cornerRadius(4)
                .accessibilityLabel(day.day.formatted(.dateTime.weekday(.wide)))
                .accessibilityValue("\(FocusText.minutes(day.focusMinutes)), \(FocusText.sessions(day.completed))")
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
            }
        }
        .chartYAxisLabel("min")
        .chartXSelection(value: $selected)
        .frame(height: 180)
    }

    private func row(_ day: DayStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(day.day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                .font(.headline)
            Text("\(FocusText.sessions(day.completed)) · \(FocusText.shortDuration(day.focusMinutes))")
            if day.quitEarly > 0 {
                Text("\(day.quitEarly) quit early").foregroundStyle(.secondary)
            }
        }
    }

    private func title(_ week: WeekStats) -> String {
        guard let first = week.days.first?.day, let last = week.days.last?.day else { return "" }
        return (first..<last).formatted(.interval.day().month(.abbreviated))
    }

    private func selectedText(_ week: WeekStats) -> String {
        guard let selected, let day = week.days.first(where: { calendar.isDate($0.day, inSameDayAs: selected) })
        else { return "Touch a bar to see that day." }
        let name = day.day.formatted(.dateTime.weekday(.abbreviated).day())
        return "\(name): \(FocusText.shortDuration(day.focusMinutes)) · \(FocusText.sessions(day.completed))"
    }

    private func move(by weeks: Int) {
        anchor = calendar.date(byAdding: .weekOfYear, value: weeks, to: anchor) ?? anchor
        selected = nil
    }
}
