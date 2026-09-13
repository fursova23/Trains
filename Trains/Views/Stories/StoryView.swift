import SwiftUI

struct StoryView: View {
    let slide: StorySlide
    let storyID: Int

    var body: some View {
        StoryImageView(name: slide.imageName, storyID: storyID)
            .overlay {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(slide.title)
                        .font(.system(size: 34, weight: .bold))
                        .lineLimit(2)
                    Text(slide.description)
                        .font(.system(size: 20))
                        .lineLimit(3)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("storyPage_\(storyID)_\(slide.id)")
    }
}
