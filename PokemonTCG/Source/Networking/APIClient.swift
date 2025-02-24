import Combine

protocol APIClient {
  func fetchCards(
    query: String?,
    pagination: PaginationRequest?,
    sortField: SortField?,
    sortOrder: SortOrder?
  ) async throws -> PaginatedResponse<[PokemonCard]>
  func fetchCardDetails(cardId: String) async throws -> PokemonCard
}
