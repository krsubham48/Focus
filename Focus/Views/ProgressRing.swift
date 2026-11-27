import SwiftUI

/// A ring that drains as the time runs out.
struct ProgressRing: View {
    /// Part of the time still left, from 0 to 1.
    let fraction: Double

    var body: some View {
        ZStack {
            Circle().stroke(Color.accentColor.opacity(0.18), lineWidth: 14)
            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityHidden(true)
    }
}
