import Combine
import Foundation

class TCGDexAPIClient: APIClient {
  private let session: URLSession
  private let cache: URLCache

  init(session: URLSession = .shared, cache: URLCache? = nil) {
    if let cache = cache {
      self.cache = cache
    } else {
      let memoryCapacity = 150 * 1024 * 1024  // 150MB memory cache
      let diskCapacity = 500 * 1024 * 1024  // 500MB disk cache
      self.cache = URLCache(
        memoryCapacity: memoryCapacity,
        diskCapacity: diskCapacity,
        diskPath: nil
      )
    }
    self.cache.removeAllCachedResponses()
    self.session = session
  }

  func fetchCards(
    query: String?,
    pagination: PaginationRequest? = nil,
    sortField: SortField? = nil,
    sortOrder: SortOrder? = nil
  ) async throws -> PaginatedResponse<[PokemonCard]> {
    let endpoint = APIEndpoint.cards(
      query: query,
      pagination: pagination,
      sortField: sortField,
      sortOrder: sortOrder
    )

    do {
      let pokemonCards: [PokemonCard] = try await fetchData(from: endpoint.url, decode: decode)

      var isLastPage = true

      if let pagination = pagination {
        // Lets assume that the last page will have less elements than the items per page
        isLastPage = pagination.itemsPerPage > pokemonCards.count
      }

      return PaginatedResponse(
        items: pokemonCards,
        page: pagination?.page ?? 1,
        isLastPage: isLastPage
      )
    } catch {
      print("❌ Error fetching cards: \(error)")
      throw error
    }

  }

  private func decodeCardDetail(data: Data) throws -> CardDetail {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let cardDetail = try CardDetailFactory.createCard(data: data)
    return cardDetail
  }

  func fetchCardDetail(cardId: String) async throws -> CardDetail {
    let endpoint = APIEndpoint.cardDetail(cardId: cardId)
    return try await fetchData(
      from: endpoint.url,
      decode: decodeCardDetail
    )
  }

  private func decode<T: Decodable>(_ data: Data) throws -> T {

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(T.self, from: data)
  }

  private func fetchData<T: Codable>(from url: URL, decode: (_ data: Data) throws -> T) async throws
    -> T
  {
    debugPrint("🔄 TCGDexAPIClient: fetchData: \(url)")
    let request = URLRequest(url: url)
    if let cachedResponse = cache.cachedResponse(for: request) {
      print("🔄 TCGDexAPIClient: fetchData: \(url) - Using cached response")
      return try decode(cachedResponse.data)
    }
    print("🔄 TCGDexAPIClient: fetchData: \(url) - No cached response")
    let (data, response) = try await session.data(for: request)
    cacheResponse(data: data, url: url)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    return try decode(data)

  }

  private func cacheResponse(data: Data, url: URL) {
    let cache = URLCache.shared
    let response = CachedURLResponse(
      response: URLResponse(
        url: url,
        mimeType: "application/json",
        expectedContentLength: data.count,
        textEncodingName: "utf-8"
      ),
      data: data
    )
    cache.storeCachedResponse(response, for: URLRequest(url: url))
  }
}
