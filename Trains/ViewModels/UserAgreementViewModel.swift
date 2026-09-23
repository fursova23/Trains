import Combine
import Foundation

@MainActor
final class UserAgreementViewModel: ObservableObject {
    @Published private(set) var state: NetworkLoadState
    @Published private(set) var request: WebPageRequest?
    @Published private(set) var loadID = UUID()
    private let agreementURL: URL?

    init(url: URL? = AppSettings.agreementURL, state: NetworkLoadState = .idle) {
        agreementURL = url
        self.state = state
        request = state == .loaded ? url.map(WebPageRequest.init) : nil
    }

    func load() async {
        guard state == .idle else { return }
        guard let agreementURL else {
            state = .failed(.server)
            return
        }
        let pageRequest = WebPageRequest(url: agreementURL)
        request = pageRequest
        state = .loading
        do {
            try await pageRequest.waitForCompletion()
            try Task.checkCancellation()
            state = .loaded
        } catch {
            if Task.isCancelled || error is CancellationError {
                request = nil
                state = .idle
            } else {
                state = .failed(AppErrorKind.from(error))
            }
        }
    }

    func retry() {
        guard case .failed = state else { return }
        request = nil
        state = .idle
        loadID = UUID()
    }
}
