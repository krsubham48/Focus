import AppIntents

/// Run by a Shortcuts "app is opened" automation. Brings Focus forward only during a session.
struct FocusGuardIntent: AppIntent {
    static let title: LocalizedStringResource = "Focus Guard"
    static let description = IntentDescription("Brings Focus forward while a focus session is running.")
    static let supportedModes: IntentModes = [.background, .foreground(.dynamic)]

    @MainActor
    func perform() async throws -> some IntentResult {
        guard AppEnvironment.model.guardTriggered() else { return .result() }
        if systemContext.currentMode.canContinueInForeground {
            try await continueInForeground(alwaysConfirm: false)
        }
        return .result()
    }
}

struct FocusShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FocusGuardIntent(), phrases: ["Run \(.applicationName) Guard"],
            shortTitle: "Focus Guard", systemImageName: "shield.fill")
    }
}
