import SwiftUI

struct StoriesCollectionView: View {
    let stories: [Story]
    @AppStorage(AppSettings.viewedStoriesKey) private var viewedStoryIDs = ""
    @State private var selectedStory: Story?

    private var viewedIDs: Set<Int> {
        Set(viewedStoryIDs.split(separator: ",").compactMap { Int($0) })
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(stories) { story in
                    Button {
                        selectedStory = story
                    } label: {
                        preview(for: story)
                    }
                    .buttonStyle(.plain)
                    .disabled(story.slides.isEmpty)
                    .accessibilityLabel("История \(story.id)")
                    .accessibilityValue(viewedIDs.contains(story.id) ? "Просмотрена" : "Не просмотрена")
                    .accessibilityIdentifier("storyPreview_\(story.id)")
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 140)
        .fullScreenCover(item: $selectedStory) { story in
            StoriesView(story: story, onViewStory: markViewed)
        }
    }

    private func preview(for story: Story) -> some View {
        let isViewed = viewedIDs.contains(story.id)
        return StoryImageView(name: story.previewImageName, storyID: story.id)
            .opacity(isViewed ? 0.5 : 1)
            .overlay(alignment: .bottomLeading) {
                Text(story.title)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .padding(8)
                    .padding(.bottom, 12)
            }
            .frame(width: 92, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isViewed ? .clear : Color("BrandBlue"), lineWidth: 4)
            }
    }

    private func markViewed(_ story: Story) {
        var ids = viewedIDs
        ids.insert(story.id)
        viewedStoryIDs = ids.sorted().map(String.init).joined(separator: ",")
    }
}
