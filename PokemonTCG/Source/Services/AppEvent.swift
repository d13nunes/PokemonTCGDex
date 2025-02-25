import Foundation

enum AppEvent {
  case showCardList
  case showCardDetails(card: PokemonCard)
  case navigateBack
}
