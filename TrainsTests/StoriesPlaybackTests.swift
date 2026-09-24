import XCTest
@testable import Trains

@MainActor
final class StoriesPlaybackTests: XCTestCase {
    func testEachSlideGetsTenSeconds() {
        let playback = StoriesPlaybackViewModel(storiesCount: 2)
        XCTAssertEqual(playback.currentIndex, 0)
        playback.advance(by: 5)
        XCTAssertEqual(playback.currentIndex, 0)
        XCTAssertEqual(playback.progress(for: 0), 0.5)
        playback.advance(by: 4.99)
        XCTAssertEqual(playback.currentIndex, 0)
        playback.advance(by: 0.01)
        XCTAssertEqual(playback.currentIndex, 1)
        XCTAssertEqual(playback.progress(for: 0), 1)
        XCTAssertEqual(playback.progress(for: 1), 0)
        XCTAssertFalse(playback.isFinished)
        playback.advance(by: 10)
        XCTAssertTrue(playback.isFinished)
    }

    func testPreviousAndNextResetSlideTime() {
        let playback = StoriesPlaybackViewModel(storiesCount: 2)
        playback.advance(by: 8)
        playback.next()
        XCTAssertEqual(playback.currentIndex, 1)
        XCTAssertEqual(playback.elapsed, 0)
        playback.advance(by: 6)
        playback.previous()
        XCTAssertEqual(playback.currentIndex, 0)
        XCTAssertEqual(playback.elapsed, 0)
        XCTAssertEqual(playback.progress(for: 1), 0)
    }

    func testPreviousOnFirstSlideRestartsIt() {
        let playback = StoriesPlaybackViewModel(storiesCount: 2)
        playback.advance(by: 8)
        playback.previous()
        XCTAssertEqual(playback.currentIndex, 0)
        XCTAssertEqual(playback.elapsed, 0)
        XCTAssertFalse(playback.isFinished)
    }

    func testNextOnLastSlideFinishesAndCannotReopenPlayback() {
        let playback = StoriesPlaybackViewModel(storiesCount: 2, initialIndex: 1)
        playback.next()
        XCTAssertTrue(playback.isFinished)
        XCTAssertEqual(playback.progress(for: 1), 1)
        playback.previous()
        playback.select(0)
        playback.advance(by: 10)
        XCTAssertEqual(playback.currentIndex, 1)
        XCTAssertTrue(playback.isFinished)
    }

    func testSingleSlideFinishesAfterTenSeconds() {
        let playback = StoriesPlaybackViewModel(storiesCount: 1)
        playback.advance(by: 9)
        XCTAssertFalse(playback.isFinished)
        playback.advance(by: 1)
        XCTAssertTrue(playback.isFinished)
        XCTAssertEqual(playback.currentIndex, 0)
    }

    func testEmptyCollectionAndInvalidInitialIndicesAreSafe() {
        let empty = StoriesPlaybackViewModel(storiesCount: 0, initialIndex: 100)
        empty.next()
        empty.previous()
        empty.advance(by: 10)
        XCTAssertTrue(empty.isFinished)
        XCTAssertEqual(empty.progress(for: 0), 0)
        XCTAssertEqual(StoriesPlaybackViewModel(storiesCount: 2, initialIndex: -1).currentIndex, 0)
        XCTAssertEqual(StoriesPlaybackViewModel(storiesCount: 2, initialIndex: 99).currentIndex, 1)
    }

    func testInvalidTimeValuesDoNotCorruptPlayback() {
        let playback = StoriesPlaybackViewModel(storiesCount: 2, secondsPerStory: .nan)
        XCTAssertEqual(playback.secondsPerStory, 10)
        playback.advance(by: -.infinity)
        playback.advance(by: .nan)
        playback.advance(by: -1)
        XCTAssertEqual(playback.elapsed, 0)
    }

    func testPausedPlaybackDoesNotAdvanceAndCancellationStopsTheClock() async throws {
        let playback = StoriesPlaybackViewModel(storiesCount: 2)
        playback.setPaused(true)
        let task = Task { await playback.run() }
        defer { task.cancel() }
        try await Task.sleep(for: .milliseconds(150))
        XCTAssertEqual(playback.elapsed, 0)
        playback.setPaused(false)
        try await Task.sleep(for: .milliseconds(150))
        XCTAssertGreaterThan(playback.elapsed, 0)
        task.cancel()
        await task.value
        let elapsed = playback.elapsed
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(playback.elapsed, elapsed)
    }

    func testEachPreviewHasItsOwnSlidesAndImageNames() {
        XCTAssertEqual(Story.mocks.count, 9)
        for story in Story.mocks {
            XCTAssertEqual(story.previewImageName, "story_preview_\(story.id)")
            XCTAssertEqual(story.slides.map(\.imageName), ["story_\(story.id)", "story_\(story.id)_2"])
        }
    }
}
