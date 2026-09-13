import SwiftUI

struct UserAgreementView: View {
    fileprivate enum LoadingState {
        case loading
        case success
        case failed(AppErrorKind)
    }

    @Environment(\.dismiss) private var dismiss
    @State private var state: LoadingState = .loading
    @State private var reloadID = UUID()
    private let agreementURL: URL?

    init() {
        agreementURL = AppSettings.agreementURL
    }

    fileprivate init(state: LoadingState, agreementURL: URL?) {
        _state = State(initialValue: state)
        self.agreementURL = agreementURL
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Пользовательское соглашение")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 36)
                HStack {
                    AppBackButton { dismiss() }
                    Spacer()
                }
            }
            .frame(height: 42)

            ZStack {
                if let agreementURL {
                    AgreementWebView(
                        url: agreementURL,
                        onLoadFinished: { state = .success },
                        onLoadFailed: { state = .failed($0) }
                    )
                    .id(reloadID)
                    .opacity(isWebViewVisible ? 1 : 0)
                }

                switch state {
                case .loading:
                    ProgressView()

                case .success:
                    EmptyView()

                case .failed(let error):
                    VStack(spacing: 16) {
                        ErrorStateView(kind: error)
                        Button("Повторить", action: retryLoading)
                            .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .accessibilityIdentifier("agreementScreen")
    }

    private var isWebViewVisible: Bool {
        if case .failed = state {
            return false
        }

        return true
    }

    private func retryLoading() {
        state = .loading
        reloadID = UUID()
    }

}

#Preview("User Agreement — Loading") {
    UserAgreementView(
        state: .loading,
        agreementURL: nil
    )
}

#Preview("User Agreement — Success") {
    UserAgreementView(
        state: .success,
        agreementURL: AppSettings.agreementURL
    )
}

#Preview("User Agreement — Failed") {
    UserAgreementView(
        state: .failed(.server),
        agreementURL: nil
    )
}
