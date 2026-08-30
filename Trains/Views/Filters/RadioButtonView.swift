import SwiftUI

struct RadioButtonView: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary, lineWidth: 2)

            if isSelected {
                Circle()
                    .fill(Color.primary)
                    .padding(5)
            }
        }
        .frame(width: 24, height: 24)
    }
}
