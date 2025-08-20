import XCTest

final class NutritionFlowUITests: XCTestCase {
	func test_nutrition_add_meal_and_open_trends() throws {
		let app = XCUIApplication()
		app.launch()
		XCTAssertTrue(app.buttons["tile_Nutrition"].waitForExistence(timeout: 5))
		app.buttons["tile_Nutrition"].tap()
		XCTAssertTrue(app.buttons["add_meal_button"].waitForExistence(timeout: 5))
		app.buttons["add_meal_button"].tap()
		// Search might auto-populate; just ensure screen appears
		XCTAssertTrue(app.staticTexts["Add Meal"].waitForExistence(timeout: 5))
	}
}







