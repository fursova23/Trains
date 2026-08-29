enum NetworkLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(AppErrorKind)
}
