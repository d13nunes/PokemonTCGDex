import Combine
import Foundation

class TCGDexAPIClient: APIClient {
  private let session: URLSession

  init(session: URLSession = .shared) {
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
      let pokemonCards: [PokemonCard] = try await fetchData(from: endpoint.url)

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

  func fetchCardDetails(cardId: String) async throws -> PokemonCard {
    let endpoint = APIEndpoint.card(cardId: cardId)
    return try await fetchData(from: endpoint.url)
  }

  private func fetchData<T: Codable>(from url: URL) async throws -> T {
    debugPrint("🔄 TCGDexAPIClient: fetchData: \(url)")
    let (data, response) = try await session.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(T.self, from: data)
  }
}
