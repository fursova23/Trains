import SwiftUI

struct StoryProgressSegmentView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(.white)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color("BrandBlue"))
                        .frame(
                            width: geometry.size.width * normalizedProgress
                        )
                }
        }
        .animation(
            progressAnimation,
            value: normalizedProgress
        )
    }

    // MARK: - Properties

    private var normalizedProgress: Double {
        min(max(progress, .zero), 1)
    }

    private var progressAnimation: Animation? {
        guard normalizedProgress > .zero,
              normalizedProgress < 1 else {
            return nil
        }

        return .linear(duration: 0.05)
    }
}

#Preview("Story Progress Segment") {
    StoryProgressSegmentView(progress: 0.45)
        .frame(width: 160, height: 6)
        .padding()
        .background(.black)
}
