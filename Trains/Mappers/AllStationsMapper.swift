import Foundation

protocol AllStationsMapping {
    func map(_ response: AllStations) -> [City]
}

struct AllStationsMapper: AllStationsMapping {
    func map(_ response: AllStations) -> [City] {
        var citiesByCode: [String: City] = [:]

        for country in response.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    guard let cityName = settlement.title?.trimmedNonEmpty else {
                        continue
                    }

                    let stations = (settlement.stations ?? []).compactMap { station -> TravelStation? in
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

                    guard !stations.isEmpty else {
                        continue
                    }

                    let cityCode = settlement.codes?.yandex_code?.trimmedNonEmpty
                        ?? "city-\(cityName.lowercased())"
                    let existingStations = citiesByCode[cityCode]?.stations ?? []
                    let uniqueStations = Dictionary(
                        (existingStations + stations).map { ($0.code, $0) },
                        uniquingKeysWith: { current, _ in current }
                    )
                    .values
                    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

                    citiesByCode[cityCode] = City(
                        code: cityCode,
                        name: cityName,
                        stations: uniqueStations
                    )
                }
            }
        }

        return citiesByCode.values.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
