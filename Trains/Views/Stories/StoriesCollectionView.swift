import SwiftUI

struct StoriesCollectionView: View {
    @StateObject private var viewModel: StoriesCollectionViewModel

    init(stories: [Story]) {
        _viewModel = StateObject(wrappedValue: StoriesCollectionViewModel(stories: stories))
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.stories) { story in
                    Button {
                        viewModel.select(story)
                    } label: {
                        preview(for: story)
                    }
                    .buttonStyle(.plain)
                    .disabled(story.slides.isEmpty)
                    .accessibilityLabel("История \(story.id)")
                    .accessibilityValue(viewModel.viewedIDs.contains(story.id) ? "Просмотрена" : "Не просмотрена")
                    .accessibilityIdentifier("storyPreview_\(story.id)")
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 140)
        .fullScreenCover(item: $viewModel.selectedStory) { story in
            StoriesView(story: story, onViewStory: viewModel.markViewed)
        }
    }

    private func preview(for story: Story) -> some View {
        let isViewed = viewModel.viewedIDs.contains(story.id)
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

}
