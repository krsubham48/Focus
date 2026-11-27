import XCTest

@MainActor
final class FlowUITests: XCTestCase {
    func testStartingShowsTheCountdownWithSixApps() {
        let app = launch("ready")
        snapshot("home")
        app.buttons["preset-20"].tap()
        app.buttons["start"].tap()
        XCTAssertTrue(app.staticTexts["countdown-time"].waitForExistence(timeout: 10))
        for id in ["phone", "messages", "whatsApp", "safari", "camera", "spotify"] {
            XCTAssertTrue(app.buttons["quick-\(id)"].exists, id)
        }
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        snapshot("countdown")
    }

    func testFirstLaunchSetsThePINAndReachesHome() {
        let app = launch("fresh")
        app.buttons["onboarding-next"].tap()
        type("1234567890", in: app)
        type("1234567890", in: app)
        app.buttons["onboarding-skip-reminders"].tap()
        app.buttons["onboarding-later"].tap()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout: 5))
    }

    private func type(_ digits: String, in app: XCUIApplication) {
        for digit in digits { app.buttons["key-\(digit)"].tap() }
    }

    private func launch(_ state: String, extra: [String: String] = [:]) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment = ["FOCUS_UITEST": "1", "FOCUS_UITEST_STATE": state].merging(extra) { $1 }
        app.launch()
        return app
    }

    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
