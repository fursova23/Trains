import Foundation

@MainActor
final class WebPageRequest: Identifiable {
    let id = UUID()
    let url: URL
    private var result: Result<Void, Error>?
    private var continuation: CheckedContinuation<Void, Error>?

    init(url: URL) { self.url = url }

    func waitForCompletion() async throws {
        try Task.checkCancellation()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                if let result {
                    continuation.resume(with: result)
                } else {
                    self.continuation = continuation
                }
            }
        } onCancel: {
            Task { @MainActor in self.complete(.failure(CancellationError())) }
        }
        try Task.checkCancellation()
    }

    func complete(_ result: Result<Void, Error>) {
        guard self.result == nil else { return }
        self.result = result
        let pending = continuation
        continuation = nil
        pending?.resume(with: result)
    }
}
