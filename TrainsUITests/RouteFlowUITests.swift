import XCTest

final class RouteFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testRouteSearchFiltersCarrierDetailsAndBackNavigation() {
        let app = launch()
        XCTAssertFalse(app.buttons["Найти"].exists)
        selectRoute(in: app)
        app.buttons["Найти"].tap()
        XCTAssertTrue(app.staticTexts["Прямой перевозчик"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Перевозчик с пересадкой"].exists)
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)
        app.buttons["Уточнить время"].tap()
        app.buttons["Нет"].tap()
        app.buttons["Применить"].tap()
        XCTAssertTrue(app.staticTexts["Прямой перевозчик"].exists)
        XCTAssertFalse(app.staticTexts["Перевозчик с пересадкой"].exists)
        app.buttons["Уточнить время"].tap()
        app.buttons["Да"].tap()
        app.buttons["Применить"].tap()
        XCTAssertTrue(app.staticTexts["Перевозчик с пересадкой"].exists)
        app.staticTexts["Прямой перевозчик"].tap()
        XCTAssertTrue(app.staticTexts["Тестовый перевозчик"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.links["support@example.com"].exists || app.buttons["support@example.com"].exists)
        XCTAssertTrue(app.links["example.com"].exists || app.buttons["example.com"].exists)
        screenshot(app, name: "Carrier-details")
        app.buttons["Назад"].tap()
        app.buttons["Назад"].tap()
        XCTAssertTrue(app.buttons["originField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.firstMatch.isHittable)
        app.buttons["Поменять местами"].tap()
        XCTAssertTrue(app.buttons["originField"].label.contains("Тула"))
    }

    @MainActor
    func testCatalogFailureRetrySearchAndEmptySearchResults() {
        let app = launch(extra: ["-ui-fail-catalog-once"])
        app.buttons["originField"].tap()
        XCTAssertTrue(app.staticTexts["Нет интернета"].waitForExistence(timeout: 5))
        app.buttons["Повторить"].tap()
        XCTAssertTrue(app.buttons["Москва"].waitForExistence(timeout: 5))
        let search = app.textFields.firstMatch
        search.tap()
        search.typeText("zzzz")
        XCTAssertTrue(app.staticTexts["Город не найден"].waitForExistence(timeout: 3))
        app.buttons["Назад"].tap()
        XCTAssertTrue(app.buttons["originField"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testScheduleFailureHasBackButtonAndRetry() {
        let app = launch(extra: ["-ui-fail-schedule-once"])
        selectRoute(in: app)
        app.buttons["Найти"].tap()
        XCTAssertTrue(app.staticTexts["Ошибка сервера"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Назад"].isHittable)
        app.buttons["Повторить"].tap()
        XCTAssertTrue(app.staticTexts["Прямой перевозчик"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testEmptyScheduleAndCancelledFilters() {
        let app = launch(extra: ["-ui-empty-schedule"])
        selectRoute(in: app)
        app.buttons["Найти"].tap()
        XCTAssertTrue(app.staticTexts["Вариантов нет"].waitForExistence(timeout: 5))
        app.buttons["Уточнить время"].tap()
        app.buttons["Нет"].tap()
        app.buttons["Назад"].tap()
        app.buttons["Уточнить время"].tap()
        XCTAssertFalse(app.buttons["Применить"].exists)
        screenshot(app, name: "Filters")
    }

    @MainActor
    private func launch(extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"] + extra
        app.launch()
        XCTAssertTrue(app.buttons["originField"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    private func selectRoute(in app: XCUIApplication) {
        app.buttons["originField"].tap()
        XCTAssertTrue(app.buttons["Москва"].waitForExistence(timeout: 5))
        app.buttons["Москва"].tap()
        app.buttons["Курский вокзал"].tap()
        XCTAssertTrue(app.buttons["destinationField"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Найти"].exists)
        app.buttons["destinationField"].tap()
        XCTAssertTrue(app.buttons["Тула"].waitForExistence(timeout: 5))
        app.buttons["Тула"].tap()
        app.buttons["Московский вокзал"].tap()
        XCTAssertTrue(app.buttons["Найти"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func screenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
