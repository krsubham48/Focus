import FocusCore
import Foundation

enum AppTab: String {
    case focus, stats, settings
}

/// Builds the one model. Needs no window: a Shortcuts action can start the app in the background.
@MainActor
enum AppEnvironment {
    static let model = makeModel()

    static var initialTab: AppTab {
        #if DEBUG
        if let screen = ProcessInfo.processInfo.environment["FOCUS_UITEST_SCREEN"], let tab = AppTab(rawValue: screen) {
            return tab
        }
        #endif
        return .focus
    }

    private static func makeModel() -> FocusModel {
        #if DEBUG
        if ProcessInfo.processInfo.environment["FOCUS_UITEST"] == "1" { return makeTestModel() }
        #endif
        let silent = SilentPlatform()
        return FocusModel(
            store: .standard, vault: PINVault(store: KeychainStore()),
            notifier: silent, opener: URLOpener(), activity: silent)
    }

    #if DEBUG
    /// A throwaway model for UI tests and screenshots, set up from the launch environment.
    private static func makeTestModel() -> FocusModel {
        let environment = ProcessInfo.processInfo.environment
        let screen = environment["FOCUS_UITEST_SCREEN"]
        let store = FocusStore(url: URL.temporaryDirectory.appending(path: "focus-uitest.json"))
        try? FileManager.default.removeItem(at: store.url)
        let vault = PINVault(store: MemorySecretStore())
        if environment["FOCUS_UITEST_STATE"] == "ready" {
            var data = FocusData()
            data.onboarded = true
            if screen == "stats" { data.history = sampleHistory() }
            try? store.save(data)
            try? vault.set("1234567890")
        }
        let silent = SilentPlatform()
        let model = FocusModel(
            store: store, vault: vault, notifier: silent, opener: silent, activity: silent,
            secondsPerMinute: environment["FOCUS_SECONDS_PER_MINUTE"].flatMap(Double.init) ?? 60)
        if screen == "countdown" { try? model.start(minutes: 20) }
        return model
    }

    private static func sampleHistory() -> [SessionRecord] {
        let plan: [(daysAgo: Int, minutes: Int, outcome: SessionOutcome)] = [
            (0, 20, .completed), (0, 30, .completed), (1, 60, .completed),
            (1, 10, .quitEarly), (2, 20, .completed), (3, 5, .completed),
        ]
        return plan.map { item in
            let start = Date.now.addingTimeInterval(-Double(item.daysAgo) * 86_400)
            return SessionRecord(
                id: UUID(), startedAt: start, endedAt: start.addingTimeInterval(Double(item.minutes) * 60),
                plannedMinutes: item.minutes, outcome: item.outcome)
        }
    }
    #endif
}
