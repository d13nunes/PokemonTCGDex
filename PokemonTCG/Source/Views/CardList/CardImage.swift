import Kingfisher
import SwiftUI

struct CardImage<Placeholder: View>: View {
  let card: PokemonCard
  let placeholderImage: Placeholder

  init(
    card: PokemonCard,
    placeholderImage: Placeholder
  ) {
    self.card = card
    self.placeholderImage = placeholderImage
  }

  var onError: ((Error) -> Void)?

  var body: some View {
    KFImage.url(card.highQualityImageURL)
      .onFailure { error in
        onError?(error)
        debugPrint(
          "🚩Error loading image from url: \(String(describing: card.highQualityImageURL)) with error: \(error)"
        )
      }
      .placeholder {
        placeholderImage
      }
      .resizable()
      .scaledToFit()
  }
}
