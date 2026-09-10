import SwiftUI

struct StoriesProgressBar: View {
    let playback: StoriesPlayback

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<playback.storiesCount, id: \.self) { index in
                GeometryReader { geometry in
                    Capsule()
                        .fill(.white)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color("BrandBlue"))
                                .frame(width: geometry.size.width * playback.progress(for: index))
                                .animation(
                                    playback.progress(for: index) > 0 && playback.progress(for: index) < 1
                                        ? .linear(duration: 0.05) : nil,
                                    value: playback.progress(for: index)
                                )
                        }
                }
            }
        }
        .frame(height: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Прогресс истории")
        .accessibilityValue("Слайд \(playback.currentIndex + 1) из \(playback.storiesCount), \(Int(playback.progress(for: playback.currentIndex) * 100)) процентов")
        .accessibilityIdentifier("storiesProgress")
    }
}
