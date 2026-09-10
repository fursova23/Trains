import Foundation

struct StoriesPlayback {
    let storiesCount: Int
    let secondsPerStory: TimeInterval
    private(set) var currentIndex: Int
    private(set) var elapsed: TimeInterval = 0

    init(storiesCount: Int, initialIndex: Int = 0, secondsPerStory: TimeInterval = 10) {
        self.storiesCount = max(storiesCount, 0)
        self.secondsPerStory = secondsPerStory.isFinite && secondsPerStory > 0 ? secondsPerStory : 10
        currentIndex = min(max(initialIndex, 0), max(storiesCount - 1, 0))
    }

    var isFinished: Bool {
        storiesCount == 0 || (currentIndex == storiesCount - 1 && elapsed >= secondsPerStory)
    }

    func progress(for index: Int) -> Double {
        guard storiesCount > 0 else { return 0 }
        if index < currentIndex { return 1 }
        if index > currentIndex { return 0 }
        return min(elapsed / secondsPerStory, 1)
    }

    mutating func select(_ index: Int) {
        guard !isFinished, (0..<storiesCount).contains(index), index != currentIndex else { return }
        currentIndex = index
        elapsed = 0
    }

    mutating func next() {
        guard !isFinished else { return }
        if currentIndex < storiesCount - 1 {
            select(currentIndex + 1)
        } else {
            elapsed = secondsPerStory
        }
    }

    mutating func previous() {
        guard !isFinished else { return }
        if currentIndex > 0 {
            select(currentIndex - 1)
        } else {
            elapsed = 0
        }
    }

    mutating func advance(by interval: TimeInterval) {
        guard !isFinished, interval.isFinite, interval > 0 else { return }
        elapsed = min(elapsed + interval, secondsPerStory)
        if elapsed >= secondsPerStory && currentIndex < storiesCount - 1 {
            next()
        }
    }
}
