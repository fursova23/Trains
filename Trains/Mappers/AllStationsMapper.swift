import Foundation

protocol AllStationsMapping {
    func map(_ response: AllStations) -> [City]
}

struct AllStationsMapper: AllStationsMapping {
    func map(_ response: AllStations) -> [City] {
        var citiesByCode: [String: City] = [:]

        for country in response.countries ?? [] {
            process(country, into: &citiesByCode)
        }

        return sortedCities(from: citiesByCode)
    }

    private func process(
        _ country: Components.Schemas.Country,
        into citiesByCode: inout [String: City]
    ) {
        for region in country.regions ?? [] {
            process(region, into: &citiesByCode)
        }
    }

    private func process(
        _ region: Components.Schemas.Region,
        into citiesByCode: inout [String: City]
    ) {
        for settlement in region.settlements ?? [] {
            process(settlement, into: &citiesByCode)
        }
    }

    private func process(
        _ settlement: Components.Schemas.Settlement,
        into citiesByCode: inout [String: City]
    ) {
        guard let cityName = settlement.title?.trimmedNonEmpty else {
            return
        }

        let stations = makeStations(from: settlement)
        guard !stations.isEmpty else {
            return
        }

        let cityCode = makeCityCode(from: settlement, cityName: cityName)
        citiesByCode[cityCode] = makeCity(
            code: cityCode,
            name: cityName,
            newStations: stations,
            existingCity: citiesByCode[cityCode]
        )
    }

    private func makeStations(
        from settlement: Components.Schemas.Settlement
    ) -> [TravelStation] {
        (settlement.stations ?? []).compactMap { station in
            let transportType = station.transport_type?.lowercased()
            guard transportType == "train" || transportType == "suburban" else {
                return nil
            }

            guard
                let name = station.title?.trimmedNonEmpty,
                let code = (station.codes?.yandex_code ?? station.code)?.trimmedNonEmpty
            else {
                return nil
            }

            return TravelStation(code: code, name: name)
        }
    }

    private func makeCityCode(
        from settlement: Components.Schemas.Settlement,
        cityName: String
    ) -> String {
        settlement.codes?.yandex_code?.trimmedNonEmpty
            ?? "city-\(cityName.lowercased())"
    }

    private func makeCity(
        code: String,
        name: String,
        newStations: [TravelStation],
        existingCity: City?
    ) -> City {
        City(
            code: code,
            name: name,
            stations: mergedStations(
                existingCity?.stations ?? [],
                with: newStations
            )
        )
    }

    private func mergedStations(
        _ existingStations: [TravelStation],
        with newStations: [TravelStation]
    ) -> [TravelStation] {
        Dictionary(
            (existingStations + newStations).map { ($0.code, $0) },
            uniquingKeysWith: { current, _ in current }
        )
        .values
        .sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    private func sortedCities(from citiesByCode: [String: City]) -> [City] {
        citiesByCode.values.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
