import Combine
import SwiftUI

struct StoriesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    let story: Story
    let onViewStory: (Story) -> Void
    @State private var playback: StoriesPlaybackViewModel
    @State private var lastTick = Date()
    @GestureState private var isDragging = false
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    init(story: Story, onViewStory: @escaping (Story) -> Void) {
        self.story = story
        self.onViewStory = onViewStory
        _playback = State(initialValue: StoriesPlaybackViewModel(storiesCount: story.slides.count))
    }

    var body: some View {
        ZStack {
            Color(.blackUniversal).ignoresSafeArea()

            if story.slides.indices.contains(playback.currentIndex) {
                GeometryReader { geometry in
                    StoryView(slide: story.slides[playback.currentIndex], storyID: story.id)
                        .id(playback.currentIndex)
                        .transition(.opacity)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            if location.x < geometry.size.width / 2 {
                                previousSlide()
                            } else {
                                nextSlide()
                            }
                        }
                        .gesture(swipeGesture)
                        .accessibilityAction(named: Text("Следующий слайд"), nextSlide)
                        .accessibilityAction(named: Text("Предыдущий слайд"), previousSlide)
                }
                .animation(.easeInOut(duration: 0.2), value: playback.currentIndex)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .overlay(alignment: .top) {
                    VStack(alignment: .trailing, spacing: 12) {
                        StoriesProgressBarView(playback: playback)
                            .allowsHitTesting(false)
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(Color(.blackUniversal), in: Circle())
                                .frame(width: 44, height: 44, alignment: .trailing)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Закрыть Stories")
                        .accessibilityIdentifier("closeStories")
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 28)
                }
                .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            lastTick = Date()
            if playback.isFinished {
                dismiss()
            } else {
                onViewStory(story)
            }
        }
        .onChange(of: playback.currentIndex) { _, _ in
            lastTick = Date()
        }
        .onChange(of: playback.isFinished) { _, isFinished in
            if isFinished {
                dismiss()
            }
        }
        .onChange(of: scenePhase) { _, _ in
            lastTick = Date()
        }
        .onChange(of: isDragging) { _, _ in
            lastTick = Date()
        }
        .onReceive(timer) { now in
            defer {
                lastTick = now
            }
            guard scenePhase == .active, !isDragging else { return }
            playback.advance(by: now.timeIntervalSince(lastTick))
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .updating($isDragging) { _, isDragging, _ in isDragging = true }
            .onEnded { value in
                let offset = value.translation
                if offset.height > 60 && offset.height > abs(offset.width) {
                    dismiss()
                } else if abs(offset.width) > 60 && abs(offset.width) > abs(offset.height) {
                    if offset.width < 0 {
                        nextSlide()
                    } else {
                        previousSlide()
                    }
                }
            }
    }

    private func nextSlide() {
        lastTick = Date()
        playback.next()
    }

    private func previousSlide() {
        lastTick = Date()
        playback.previous()
    }
}
