import Combine
import Foundation

@MainActor
@Observable
class CardDetailsViewModel {
  private let apiClient: APIClient
  let card: PokemonCard
  private var cardDetail: CardDetail?

  var cardName: String { card.name }
  var imageUrl: URL? { card.highQualityImageURL }

  private(set) var loadingState: LoadingState = .idle
  private(set) var errorMessage: String?

  var commonInformation: CardDetail? { cardDetail }
  var pokemonInformation: PokemonCardDetail? { cardDetail?.pokemon }
  var trainerInformation: TrainerCardDetail? { cardDetail?.trainer }
  var energyInformation: EnergyCardDetail? { cardDetail?.energy }

  init(apiClient: APIClient, card: PokemonCard) {
    self.card = card
    self.apiClient = apiClient
  }

  func onViewAppeared() {
    loadingState = .loading
    Task {
      do {
        self.cardDetail = try await apiClient.fetchCardDetail(cardId: card.id)
        print("🚩CardDetailsViewModel cardDetail: \(cardDetail)")
        loadingState = .loaded
      } catch {
        print("Error fetching card details: \(error)")
        errorMessage = "Error fetching card details"
        loadingState = .error(error)
      }
    }
  }

  // Add any additional methods for card detail interactions here
  func shareCard() {
    // Implementation for sharing card details
  }

  func addToFavorites() {
    // Implementation for adding card to favorites
  }
}
