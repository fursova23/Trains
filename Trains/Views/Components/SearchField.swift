import SwiftUI

struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(text.isEmpty ? Color.secondary : Color.primary)

            TextField("Введите запрос", text: $text)
                .font(.system(size: 17))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Очистить поиск")
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
        .background(Color(uiColor: .secondarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
