import SwiftUI

struct ErrorStateView: View {
    let kind: AppErrorKind

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .accessibilityHidden(true)

            Text(kind.title)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var imageName: String {
        switch kind {
        case .noInternet:
            "no_internet_error"
        case .server:
            "server_error"
        }
    }
}

#Preview("Нет интернета") {
    ErrorStateView(kind: .noInternet)
}

#Preview("Ошибка сервера") {
    ErrorStateView(kind: .server)
        .preferredColorScheme(.dark)
}
