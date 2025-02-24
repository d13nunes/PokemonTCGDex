import Foundation

struct PaginationRequest {
  let page: Int
  let itemsPerPage: Int

  var queryItems: [URLQueryItem] {
    [
      URLQueryItem(name: "pagination:page", value: String(page)),
      URLQueryItem(name: "pagination:itemsPerPage", value: String(itemsPerPage)),
    ]
  }
}

struct PaginatedResponse<T: Codable>: Codable {
  let items: T
  let page: Int
  let isLastPage: Bool
}
