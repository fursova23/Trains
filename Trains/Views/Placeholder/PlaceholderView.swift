import SwiftUI

struct PlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var showsBackButton = false

    var body: some View {
        VStack(spacing: 0) {
            if showsBackButton {
                HStack {
                    AppBackButton { dismiss() }
                    Spacer()
                }
                .padding(.horizontal, 4)
            }

            Spacer()

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }
}
