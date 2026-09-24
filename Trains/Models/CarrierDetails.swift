import Foundation

struct CarrierDetails: Sendable {
    let name: String
    let logoURL: URL?
    let email: String?
    let phone: String?
    var websiteURL: URL?

    var emailURL: URL? {
        guard let email else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        return components.url
    }

    var phoneURL: URL? {
        guard let phone else { return nil }
        let number = phone.filter { $0.isNumber || $0 == "+" }
        guard !number.isEmpty else { return nil }
        return URL(string: "tel:\(number)")
    }
}
