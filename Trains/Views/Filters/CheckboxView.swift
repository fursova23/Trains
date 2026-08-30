import SwiftUI

struct CheckboxView: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(isSelected ? Color.primary : Color.clear)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.primary, lineWidth: 2)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
        }
        .frame(width: 24, height: 24)
    }
}
