import FocusCore
import LocalAuthentication
import SwiftUI
import UserNotifications

struct SettingsView: View {
    let model: FocusModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var pinChange: PINChange?
    @State private var notificationsOn = false

    private struct PINChange: Identifiable {
        let requireCurrent: Bool
        var id: Bool { requireCurrent }
    }

    private var hasPasscode: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    var body: some View {
        NavigationStack {
            List {
                Section("PIN") {
                    Button("Change PIN") { pinChange = PINChange(requireCurrent: true) }
                        .accessibilityIdentifier("change-pin")
                    if hasPasscode {
                        Button("Forgot PIN") { confirmOwner() }
                    }
                }
                Section("Reminders") {
                    Text("Notifications: \(notificationsOn ? "On" : "Off")")
                    Button("Open iOS Settings") {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
                    }
                    Text("If you use Do Not Disturb or another Focus mode, allow this app's notifications in it.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if !hasPasscode {
                        Text("Set an iPhone passcode so Focus can tell locking from leaving.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Section {
                    NavigationLink("App guard") { GuardGuideView(model: model) }
                }
                Section {
                    Text("Everything stays on this phone. No network.")
                    Text("Version \(version)").foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .sheet(item: $pinChange) { change in
                ChangePINView(model: model, requireCurrent: change.requireCurrent)
            }
            .task(id: scenePhase) {
                notificationsOn = await NotificationStatus.current() == .authorized
            }
        }
    }

    /// Face ID or the phone passcode stands in for the forgotten PIN.
    private func confirmOwner() {
        LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Reset your Focus PIN") { success, _ in
            guard success else { return }
            Task { @MainActor in pinChange = PINChange(requireCurrent: false) }
        }
    }
}
