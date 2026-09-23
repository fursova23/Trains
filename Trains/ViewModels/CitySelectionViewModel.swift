import Combine
import Foundation

@MainActor
final class CitySelectionViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var cities: [City] = []
    @Published private(set) var state: NetworkLoadState = .idle
    @Published private(set) var loadID = UUID()

    private let repository: StationCatalogRepositoryProtocol

    var filteredCities: [City] {
        let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return search.isEmpty ? cities : cities.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    init(repository: StationCatalogRepositoryProtocol) {
        self.repository = repository
    }

    func retry() { loadID = UUID() }

    func load() async {
        guard state != .loading, state != .loaded else { return }
        state = .loading
        do {
            let cities = try await repository.fetchCities()
            try Task.checkCancellation()
            self.cities = cities
            state = .loaded
        } catch {
            state = Task.isCancelled || error is CancellationError ? .idle : .failed(AppErrorKind.from(error))
        }
    }
}
