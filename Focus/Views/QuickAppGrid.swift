import FocusCore
import SwiftUI

struct QuickAppGrid: View {
    let model: FocusModel

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(QuickApp.allCases) { app in
                Button {
                    Task { await model.open(app) }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: app.symbol).font(.title2)
                        Text(app.title)
                            .font(.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("quick-\(app.rawValue)")
            }
        }
    }
}
