import SwiftUI

struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UserAgreementViewModel

    init(viewModel: @autoclosure @escaping () -> UserAgreementViewModel = UserAgreementViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
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
                if let request = viewModel.request {
                    AgreementWebView(request: request)
                    .id(request.id)
                    .opacity(viewModel.state == .loaded ? 1 : 0)
                }

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()

                case .loaded:
                    EmptyView()

                case .failed(let error):
                    VStack(spacing: 16) {
                        ErrorStateView(kind: error)
                        Button("Повторить", action: viewModel.retry)
                            .padding(.bottom, 24)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task(id: viewModel.loadID) { await viewModel.load() }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .accessibilityIdentifier("agreementScreen")
    }

}

#Preview("User Agreement — Loading") {
    UserAgreementView(viewModel: UserAgreementViewModel(url: nil, state: .loading))
}

#Preview("User Agreement — Success") {
    UserAgreementView(viewModel: UserAgreementViewModel(state: .loaded))
}

#Preview("User Agreement — Failed") {
    UserAgreementView(viewModel: UserAgreementViewModel(url: nil, state: .failed(.server)))
}
