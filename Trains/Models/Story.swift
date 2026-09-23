import Foundation

struct Story: Identifiable, Sendable {
    let id: Int
    let previewImageName: String
    let title: String
    let slides: [StorySlide]

    static let mocks: [Story] = (1...9).map { number in
        Story(
            id: number,
            previewImageName: "story_preview_\(number)",
            title: Array(repeating: "Text", count: 12).joined(separator: " "),
            slides: (1...2).map { slideNumber in
                StorySlide(
                    id: slideNumber,
                    imageName: slideNumber == 1 ? "story_\(number)" : "story_\(number)_2",
                    title: Array(repeating: "Text", count: 12).joined(separator: " "),
                    description: Array(repeating: "Text", count: 35).joined(separator: " ")
                )
            }
        )
    }
}
