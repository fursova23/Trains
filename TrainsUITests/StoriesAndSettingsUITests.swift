import XCTest

final class StoriesAndSettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSelectedGroupTapSwipeCloseAndViewedState() {
        let app = XCUIApplication()
        app.launch()
        let preview = app.buttons["storyPreview_2"]
        XCTAssertTrue(preview.waitForExistence(timeout: 10))
        preview.tap()
        assertSlide(1, storyID: 2, in: app)
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5)).tap()
        assertSlide(2, storyID: 2, in: app)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5)).tap()
        assertSlide(1, storyID: 2, in: app)
        app.swipeLeft()
        assertSlide(2, storyID: 2, in: app)
        app.swipeRight()
        assertSlide(1, storyID: 2, in: app)

        saveScreenshot(app, name: "Stories-first-slide")
        app.buttons["closeStories"].tap()
        XCTAssertTrue(preview.waitForExistence(timeout: 5))
        XCTAssertEqual(preview.value as? String, "Просмотрена")
        XCTAssertTrue(app.tabBars.firstMatch.isHittable)
    }

    @MainActor
    func testDownwardSwipeClosesStories() {
        let app = XCUIApplication()
        app.launch()
        let preview = app.buttons["storyPreview_1"]
        XCTAssertTrue(preview.waitForExistence(timeout: 10))
        preview.tap()
        assertSlide(1, storyID: 1, in: app)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8)))
        XCTAssertTrue(preview.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["closeStories"].exists)
    }

    @MainActor
    func testLastSlideClosesOnTapAndReopeningStartsFromBeginning() {
        let app = XCUIApplication()
        app.launch()
        let preview = app.buttons["storyPreview_2"]
        XCTAssertTrue(preview.waitForExistence(timeout: 10))
        preview.tap()
        assertSlide(1, storyID: 2, in: app)
        let rightSide = app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        rightSide.tap()
        assertSlide(2, storyID: 2, in: app)
        rightSide.tap()
        XCTAssertTrue(preview.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["closeStories"].exists)
        preview.tap()
        assertSlide(1, storyID: 2, in: app)
        app.swipeLeft()
        assertSlide(2, storyID: 2, in: app)
        app.swipeLeft()
        XCTAssertTrue(preview.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTimerAdvancesAfterTenSecondsAndClosesSelectedGroup() {
        let app = XCUIApplication()
        app.launch()
        let preview = app.buttons["storyPreview_1"]
        XCTAssertTrue(preview.waitForExistence(timeout: 10))
        preview.tap()
        assertSlide(1, storyID: 1, in: app)
        let progress = app.otherElements["storiesProgress"]
        let secondSlide = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "Слайд 2 из 2"), object: progress
        )
        secondSlide.isInverted = true
        // На пятой секунде первый слайд ещё должен оставаться на экране
        wait(for: [secondSlide], timeout: 4)
        let transition = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "Слайд 2 из 2"), object: progress
        )
        wait(for: [transition], timeout: 7)
        assertSlide(2, storyID: 1, in: app)
        saveScreenshot(app, name: "Stories-second-slide")
        let closed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: app.buttons["closeStories"]
        )
        wait(for: [closed], timeout: 12)
        XCTAssertTrue(preview.isHittable)
        XCTAssertFalse(app.buttons["closeStories"].exists)
        XCTAssertTrue(app.tabBars.firstMatch.isHittable)
    }

    @MainActor
    private func assertSlide(_ slide: Int, storyID: Int, in app: XCUIApplication) {
        let progress = app.otherElements["storiesProgress"]
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "Слайд \(slide) из 2"), object: progress
        )
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "storyPage_\(storyID)_\(slide)").firstMatch.exists)
    }

    @MainActor
    func testThemePersistsAndAgreementCoversTabBar() {
        let app = XCUIApplication()
        app.launch()
        let settingsTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()
        let toggle = app.switches["darkThemeToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String == "1" { tapSwitch(toggle) }
        tapSwitch(toggle)
        XCTAssertEqual(toggle.value as? String, "1")
        saveScreenshot(app, name: "Settings-dark")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["storyPreview_1"].waitForExistence(timeout: 10))
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.switches["darkThemeToggle"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.switches["darkThemeToggle"].value as? String, "1")
        app.buttons["openAgreement"].tap()
        XCTAssertTrue(app.buttons["Назад"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)
        app.buttons["Назад"].tap()
        XCTAssertTrue(app.switches["darkThemeToggle"].waitForExistence(timeout: 5))
        tapSwitch(app.switches["darkThemeToggle"])
        saveScreenshot(app, name: "Settings-light")
        app.tabBars.buttons.element(boundBy: 0).tap()
        saveScreenshot(app, name: "Main-light")
    }

    @MainActor
    private func tapSwitch(_ toggle: XCUIElement) {
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.94, dy: 0.5)).tap()
    }

    @MainActor
    private func saveScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
