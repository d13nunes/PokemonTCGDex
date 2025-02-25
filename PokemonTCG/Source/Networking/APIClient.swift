import Combine

protocol APIClient {
  func fetchCards(
    query: String?,
    pagination: PaginationRequest?,
    sortField: SortField?,
    sortOrder: SortOrder?
  ) async throws -> PaginatedResponse<[PokemonCard]>
  func fetchCardDetail(cardId: String) async throws -> CardDetail
}
