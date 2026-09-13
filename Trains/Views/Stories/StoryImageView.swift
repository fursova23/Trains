import SwiftUI
import UIKit

struct StoryImageView: View {
    let name: String
    let storyID: Int

    var body: some View {
        GeometryReader { geometry in
            Group {
                let image = UIImage(named: name)
                Image(uiImage: image ?? UIImage())
                        .resizable()
                        .scaledToFill()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .accessibilityHidden(true)
    }
}
