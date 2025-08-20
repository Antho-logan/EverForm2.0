import XCTest

final class MainMenuNavigationUITests: XCTestCase {
	func test_tap_all_tiles() throws {
		let app = XCUIApplication()
		app.launch()
		// Assuming route to Home first; ensure create account path navigates to MainMenu quickly
		if app.buttons["create_account_button"].waitForExistence(timeout: 3) {
			app.buttons["create_account_button"].tap()
			if app.buttons["create_account_primary_button"].waitForExistence(timeout: 3) {
				app.buttons["create_account_primary_button"].tap()
			}
			if app.buttons["onboarding_profile_next_button"].waitForExistence(timeout: 3) {
				app.buttons["onboarding_profile_next_button"].tap()
			}
			if app.buttons["onboarding_preferences_finish_button"].waitForExistence(timeout: 3) {
				app.buttons["onboarding_preferences_finish_button"].tap()
			}
		}

		let tiles = ["tile_Training","tile_Nutrition","tile_Sleep & Recovery","tile_Mobility","tile_Supplements","tile_Progress","tile_Settings"]
		for tile in tiles {
			XCTAssertTrue(app.buttons[tile].waitForExistence(timeout: 5))
			app.buttons[tile].tap()
			XCTAssertTrue(app.staticTexts.element(boundBy: 0).waitForExistence(timeout: 2))
			app.swipeRight()
		}
	}
}

