import Combine
import Foundation

@MainActor
final class StoriesCollectionViewModel: ObservableObject {
    @Published var selectedStory: Story?
    @Published private(set) var viewedIDs: Set<Int>
    let stories: [Story]
    private let userDefaults: UserDefaults

    init(stories: [Story], userDefaults: UserDefaults = .standard) {
        self.stories = stories
        self.userDefaults = userDefaults
        viewedIDs = Set((userDefaults.string(forKey: AppSettings.viewedStoriesKey) ?? "")
            .split(separator: ",").compactMap { Int($0) })
    }

    func select(_ story: Story) {
        guard !story.slides.isEmpty else { return }
        selectedStory = story
    }

    func markViewed(_ story: Story) {
        viewedIDs.insert(story.id)
        userDefaults.set(viewedIDs.sorted().map(String.init).joined(separator: ","),
                         forKey: AppSettings.viewedStoriesKey)
    }
}
