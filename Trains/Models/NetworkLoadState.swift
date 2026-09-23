enum NetworkLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case failed(AppErrorKind)
}
