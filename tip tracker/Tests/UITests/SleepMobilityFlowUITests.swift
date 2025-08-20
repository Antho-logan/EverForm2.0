import XCTest

final class SleepMobilityFlowUITests: XCTestCase {
	func test_sleep_mobility_flow() throws {
		let app = XCUIApplication()
		app.launch()
		// Sleep tile
		XCTAssertTrue(app.buttons["tile_Sleep & Recovery"].waitForExistence(timeout: 5))
		app.buttons["tile_Sleep & Recovery"].tap()
		// Wind-Down start button exists
		XCTAssertTrue(app.buttons["wind_start_button"].waitForExistence(timeout: 5))
		// Back to menu
		app.navigationBars.buttons.firstMatch.tap()
		// Mobility tile
		XCTAssertTrue(app.buttons["tile_Mobility"].waitForExistence(timeout: 5))
		app.buttons["tile_Mobility"].tap()
		XCTAssertTrue(app.buttons.matching(identifier: NSPredicate(format: "SELF BEGINSWITH 'mob_start_'")).firstMatch.waitForExistence(timeout: 5))
	}
}







