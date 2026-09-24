import Combine
import Foundation

@MainActor
class NetworkLoadingViewModel: ObservableObject {
    @Published private(set) var state: NetworkLoadState = .idle
    @Published private(set) var loadID = UUID()

    final func retry() {
        loadID = UUID()
    }

    final func load<Value>(
        operation: () async throws -> Value,
        onSuccess: (Value) -> Void
    ) async {
        guard state != .loading, state != .loaded else { return }

        state = .loading

        do {
            let value = try await operation()
            try Task.checkCancellation()
            onSuccess(value)
            state = .loaded
        } catch {
            state = Task.isCancelled || error is CancellationError
                ? .idle
                : .failed(AppErrorKind.from(error))
        }
    }
}
