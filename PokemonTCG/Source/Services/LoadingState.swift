enum LoadingState: Equatable {
  case idle, loading, loaded
  case error(Error)

  static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
      return true
    case (.error, .error):
      return true
    default:
      return false
    }
  }
}
