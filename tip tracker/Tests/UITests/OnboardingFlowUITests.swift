import XCTest

final class OnboardingFlowUITests: XCTestCase {
	func test_onboarding_flow_guest() throws {
		let app = XCUIApplication()
		app.launch()

		XCTAssertTrue(app.buttons["continue_guest_button"].waitForExistence(timeout: 5))
		app.buttons["continue_guest_button"].tap()

		XCTAssertTrue(app.buttons["onboarding_profile_next_button"].waitForExistence(timeout: 5))
		app.buttons["onboarding_profile_next_button"].tap()

		XCTAssertTrue(app.buttons["onboarding_preferences_finish_button"].waitForExistence(timeout: 5))
		app.buttons["onboarding_preferences_finish_button"].tap()

		XCTAssertTrue(app.buttons["tile_Training"].waitForExistence(timeout: 5))
	}
}

