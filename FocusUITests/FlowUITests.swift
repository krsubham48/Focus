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

    private func answerSum(in app: XCUIApplication) {
        let parts = app.staticTexts["sum-text"].label.split(separator: " ")
        let (a, b) = (Int(parts[0])!, Int(parts[2])!)
        type(String(parts[1] == "+" ? a + b : a - b), in: app)
        app.buttons["key-enter"].tap()
    }

    func testOverrideNeedsPINFiveSumsConfirmationAndPINAgain() {
        let app = launch("ready")
        app.buttons["preset-20"].tap()
        app.buttons["start"].tap()
        app.buttons["override"].tap()
        type("1234567890", in: app)
        for _ in 0..<5 { answerSum(in: app) }
        app.buttons["confirm-yes"].tap()
        type("1234567890", in: app)
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Stats"].tap()
        XCTAssertTrue(app.staticTexts["1 quit early"].waitForExistence(timeout: 5))
    }

    func testTimeRunningOutClosesOverride() {
        let app = launch("ready", extra: ["FOCUS_SECONDS_PER_MINUTE": "3"])
        app.buttons["preset-5"].tap()
        app.buttons["start"].tap()
        app.buttons["override"].tap()
        XCTAssertTrue(app.buttons["override-cancel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["override-cancel"].waitForNonExistence(timeout: 30))
        XCTAssertFalse(app.staticTexts["countdown-time"].exists)
    }

    func testAFinishedSessionShowsDoneAndCountsInStats() {
        let app = launch("ready", extra: ["FOCUS_SECONDS_PER_MINUTE": "3"])
        app.buttons["preset-1"].tap()
        app.buttons["start"].tap()
        XCTAssertTrue(app.staticTexts["Done. You focused for 1 minute."].waitForExistence(timeout: 20))
        app.buttons["done-close"].tap()
        app.tabBars.buttons["Stats"].tap()
        XCTAssertTrue(app.staticTexts["stats-total"].label.contains("1 session"))
        snapshot("stats")
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
