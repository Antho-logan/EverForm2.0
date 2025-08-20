import XCTest

final class TrainingFlowUITests: XCTestCase {
	func test_training_quick_start_finish() throws {
		let app = XCUIApplication()
		app.launch()
		// Navigate: Main menu -> Training
		XCTAssertTrue(app.buttons["tile_Training"].waitForExistence(timeout: 5))
		app.buttons["tile_Training"].tap()
		// Expect Start buttons exist
		XCTAssertTrue(app.buttons.matching(identifier: NSPredicate(format: "SELF BEGINSWITH 'start_workout_button_'")).firstMatch.waitForExistence(timeout: 5))
		app.buttons.matching(identifier: NSPredicate(format: "SELF BEGINSWITH 'start_workout_button_'")).firstMatch.tap()
		// Session appears; finish
		XCTAssertTrue(app.buttons["finish_workout_button"].waitForExistence(timeout: 5))
		app.buttons["finish_workout_button"].tap()
	}
}







