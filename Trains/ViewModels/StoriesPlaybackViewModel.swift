import Combine
import Foundation

@MainActor
final class StoriesPlaybackViewModel: ObservableObject {
    let storiesCount: Int
    let secondsPerStory: TimeInterval
    @Published private(set) var currentIndex: Int
    @Published private(set) var elapsed: TimeInterval = 0

    private var lastTick = ContinuousClock.now
    private var isPaused = false

    func setPaused(_ paused: Bool) {
        isPaused = paused
        lastTick = .now
    }

    func run() async {
        lastTick = .now
        do {
            while !isFinished {
                try await Task.sleep(for: .milliseconds(50))
                try Task.checkCancellation()
                let now = ContinuousClock.now
                let duration = lastTick.duration(to: now).components
                lastTick = now
                if !isPaused {
                    advance(by: Double(duration.seconds) + Double(duration.attoseconds) / 1e18)
                }
            }
        } catch {
            // Закрытие экрана отменяет task и останавливает воспроизведение
        }
    }

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

    func select(_ index: Int) {
        guard !isFinished, (0..<storiesCount).contains(index), index != currentIndex else { return }
        currentIndex = index
        elapsed = 0
        lastTick = .now
    }

    func next() {
        guard !isFinished else { return }
        if currentIndex < storiesCount - 1 {
            select(currentIndex + 1)
        } else {
            elapsed = secondsPerStory
        }
    }

    func previous() {
        guard !isFinished else { return }
        if currentIndex > 0 {
            select(currentIndex - 1)
        } else {
            elapsed = 0
            lastTick = .now
        }
    }

    func advance(by interval: TimeInterval) {
        guard !isFinished, interval.isFinite, interval > 0 else { return }
        elapsed = min(elapsed + interval, secondsPerStory)
        if elapsed >= secondsPerStory && currentIndex < storiesCount - 1 {
            next()
        }
    }
}
