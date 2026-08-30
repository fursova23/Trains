import Foundation

enum AppErrorKind: String, Equatable {
    case noInternet
    case server

    var title: String {
        switch self {
        case .noInternet: "Нет интернета"
        case .server: "Ошибка сервера"
        }
    }

    static func from(_ error: Error) -> AppErrorKind {
        if containsConnectionError(error as NSError) {
            return .noInternet
        }

        return .server
    }

    private static func containsConnectionError(_ error: NSError) -> Bool {
        let connectionErrorCodes: Set<Int> = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorCannotFindHost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorDNSLookupFailed,
            NSURLErrorTimedOut
        ]

        if error.domain == NSURLErrorDomain, connectionErrorCodes.contains(error.code) {
            return true
        }

        if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
            return containsConnectionError(underlyingError)
        }

        return false
    }
}
