import Foundation

protocol CarrierTripMapping {
    func map(_ response: ScheduleBetweenStations) -> [CarrierTrip]
}

struct CarrierTripMapper: CarrierTripMapping {
    func map(_ response: ScheduleBetweenStations) -> [CarrierTrip] {
        response.segments?.compactMap(makeTrip(from:)) ?? []
    }

    private func makeTrip(from segment: Components.Schemas.Segment) -> CarrierTrip? {
        guard let departure = segment.departure,
              let arrival = segment.arrival else {
            return nil
        }

        let carrier = segment.thread?.carrier
        let carrierName = carrier?.title?.trimmedNonEmpty
            ?? segment.thread?.title?.trimmedNonEmpty
            ?? "Перевозчик"
        let duration = segment.duration
            ?? max(0, Int(arrival.timeIntervalSince(departure)))
        let routeIdentifier = segment.thread?.uid
            ?? "\(segment.from?.code ?? "from")-\(segment.to?.code ?? "to")"
        let id = "\(routeIdentifier)-\(departure.timeIntervalSince1970)"

        return CarrierTrip(
            id: id,
            carrierCode: carrier?.code,
            carrierName: carrierName,
            logoURL: makeURL(from: carrier?.logo),
            departure: departure,
            arrival: arrival,
            duration: duration,
            hasTransfer: segment.thread == nil
        )
    }

    private func makeURL(from value: String?) -> URL? {
        guard let value = value?.trimmedNonEmpty else { return nil }

        if value.hasPrefix("//") {
            return URL(string: "https:\(value)")
        }

        return URL(string: value)
    }
}
