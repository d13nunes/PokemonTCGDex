import Foundation

enum AppRoute: Hashable {
  case cardList
  case cardDetails(card: PokemonCard)
}
