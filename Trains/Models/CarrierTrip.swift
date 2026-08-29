import Foundation

struct CarrierTrip: Identifiable, Hashable {
    let id: String
    let carrierCode: Int?
    let carrierName: String
    let logoURL: URL?
    let departure: Date
    let arrival: Date
    let duration: Int
    let hasTransfer: Bool

    var departureHour: Int {
        Calendar.current.component(.hour, from: departure)
    }

    var dateText: String {
        departure.formatted(
            .dateTime
                .day()
                .month(.wide)
                .locale(Locale(identifier: "ru_RU"))
        )
    }

    var departureText: String {
        departure.formatted(.dateTime.hour().minute())
    }

    var arrivalText: String {
        arrival.formatted(.dateTime.hour().minute())
    }

    var durationText: String {
        let hours = duration / 3_600
        let minutes = duration % 3_600 / 60

        if hours == 0 {
            return "\(minutes) мин"
        }

        if minutes == 0 {
            return "\(hours) ч"
        }

        return "\(hours) ч \(minutes) мин"
    }

    var transferDescription: String? {
        hasTransfer ? "С пересадками" : nil
    }
}
