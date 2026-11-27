import FocusCore
import SwiftUI

/// First launch: what Focus does, a PIN, reminders and the optional guard.
struct OnboardingView: View {
    let model: FocusModel

    private enum Step: Equatable {
        case welcome, createPIN, confirmPIN(String), reminders, appGuard
    }

    @State private var step = Step.welcome
    @State private var pinMessage = "You'll need it to end a session early."
    @State private var showingGuide = false

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(isPresented: $showingGuide) {
                    GuardGuideView(model: model, onDone: { model.finishOnboarding() })
                }
        }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case .welcome:
            page(
                title: "Focus",
                text: "Focus helps you work without drifting. Pick a time and stay with it. Calls, messages and your essentials stay one tap away. Everything stays on this phone."
            ) {
                primary("Continue", id: "onboarding-next") { step = .createPIN }
            }
        case .createPIN:
            PINEntryView(title: "Create a 10-digit PIN", message: pinMessage) { step = .confirmPIN($0) }
                .id("create")
        case .confirmPIN(let first):
            PINEntryView(title: "Enter it again") { second in
                if second == first, (try? model.vault.set(second)) != nil {
                    step = .reminders
                } else {
                    pinMessage = "Those didn't match. Try again."
                    step = .createPIN
                }
            }
            .id("confirm")
        case .reminders:
            page(title: "Reminders", text: "Focus can remind you when you drift and tell you when time is up.") {
                primary("Allow notifications", id: "onboarding-allow-reminders") {
                    Task {
                        await model.requestReminderPermission()
                        step = .appGuard
                    }
                }
                secondary("Not now", id: "onboarding-skip-reminders") { step = .appGuard }
            }
        case .appGuard:
            page(
                title: "App guard (optional)",
                text: "Set up a Shortcuts automation once, and opening a distracting app during a session brings you back to Focus."
            ) {
                primary("Set up", id: "onboarding-setup-guard") { showingGuide = true }
                secondary("Later", id: "onboarding-later") { model.finishOnboarding() }
            }
        }
    }

    private func page(title: String, text: String, @ViewBuilder buttons: () -> some View) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(title).font(.largeTitle.weight(.bold))
                Text(text).font(.title3).foregroundStyle(.secondary)
                VStack(spacing: 8) { buttons() }.padding(.top, 20)
            }
            .multilineTextAlignment(.center)
            .padding(24)
            .padding(.top, 60)
            .frame(maxWidth: .infinity)
        }
    }

    private func primary(_ title: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier(id)
    }

    private func secondary(_ title: String, id: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier(id)
    }
}
