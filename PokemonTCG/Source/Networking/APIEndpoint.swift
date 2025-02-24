import Foundation

enum SortField: String, CaseIterable {
  case name
  case id
}

enum SortOrder: String, CaseIterable {
  case asc
  case desc
}

enum APIEndpoint {
  static let baseURL = URL(string: "https://api.tcgdex.dev/v2")!

  case cards(
    query: String?,
    pagination: PaginationRequest?,
    sortField: SortField?,
    sortOrder: SortOrder?
  )
  case card(cardId: String)

  var url: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.tcgdex.net"

    switch self {
    case .cards(let query, let pagination, let sortField, let sortOrder):
      components.path = "/v2/en/cards"
      var queryItems: [URLQueryItem] = []

      if let query = query,
        !query.isEmpty
      {
        queryItems.append(URLQueryItem(name: "name", value: query))
      }

      let sortField = sortField ?? .name
      let sortOrder = sortOrder ?? .asc

      queryItems.append(URLQueryItem(name: "sort:field", value: sortField.rawValue))
      queryItems.append(URLQueryItem(name: "sort:order", value: sortOrder.rawValue.uppercased()))
      // queryItems.append(URLQueryItem(name: "effect", value: "null:"))

      if let pagination = pagination {
        queryItems.append(contentsOf: pagination.queryItems)
      }

      components.queryItems = queryItems.isEmpty ? nil : queryItems

    case .card(let cardId):
      components.path = "/v2/en/cards/\(cardId)"
    }

    guard let url = components.url else {
      preconditionFailure("Invalid URL components: \(components)")
    }

    return url
  }
}
