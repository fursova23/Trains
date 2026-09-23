import SwiftUI

struct StoriesProgressBarView: View {
    @ObservedObject var playback: StoriesPlaybackViewModel

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<playback.storiesCount, id: \.self) { index in
                StoryProgressSegmentView(
                    progress: playback.progress(for: index)
                )
            }
        }
        .frame(height: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Прогресс истории")
        .accessibilityValue(accessibilityProgress)
        .accessibilityIdentifier("storiesProgress")
    }

    // MARK: - Accessibility

    private var accessibilityProgress: String {
        guard playback.storiesCount > 0 else {
            return "Нет историй"
        }

        let currentStory = playback.currentIndex + 1
        let storiesCount = playback.storiesCount
        let progress = playback.progress(for: playback.currentIndex)
        let percentage = Int(progress * 100)

        return "Слайд \(currentStory) из \(storiesCount), \(percentage) процентов"
    }
}

#Preview("Stories Progress Bar") {
    StoriesProgressBarView(
        playback: StoriesPlaybackViewModel(
            storiesCount: 3,
            initialIndex: 1
        )
    )
    .padding()
    .background(.black)
}
