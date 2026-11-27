import XCTest

@MainActor
final class FlowUITests: XCTestCase {
    func testLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Focus"].waitForExistence(timeout: 10))
    }
}
