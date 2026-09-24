import Combine
import Foundation

@MainActor
final class CitySelectionViewModel: NetworkLoadingViewModel {
    @Published var query = ""
    @Published private(set) var cities: [City] = []

    private let repository: StationCatalogRepositoryProtocol

    var filteredCities: [City] {
        let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return search.isEmpty ? cities : cities.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    init(repository: StationCatalogRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    func load() async {
        await load(
            operation: { try await repository.fetchCities() },
            onSuccess: { cities = $0 }
        )
    }
}
