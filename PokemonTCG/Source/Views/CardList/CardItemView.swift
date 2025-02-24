import Kingfisher
import SwiftUI

struct CardItemView: View {
  let card: PokemonCard
  let imageCardWidth: CGFloat
  let imageCardHeight: CGFloat
  @State private var showError: Bool = false

  init(card: PokemonCard, width: CGFloat = 245, height: CGFloat = 337) {
    self.card = card
    self.imageCardWidth = width
    self.imageCardHeight = height
  }

  var body: some View {
    if showError {
      failureImage
    } else {
      cardImage
    }
  }

  private var failureImage: some View {
    ZStack(alignment: .topTrailing) {
      placeholderImage
      Image(systemName: "exclamationmark.triangle")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(.red)
        .frame(maxWidth: imageCardWidth * 0.1, maxHeight: imageCardHeight * 0.1)
        .padding(.top, 8)
        .padding(.trailing, 8)
    }
    .aspectRatio(contentMode: .fit)
    .frame(width: imageCardWidth, height: imageCardHeight)
  }

  private var placeholderImage: some View {
    ZStack(alignment: .bottom) {
      Image("card_placeholder")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .overlay(Color.black.opacity(0.2))
      Text(card.name)
        .font(.headline)
        .foregroundColor(.white)
        .bold()
        .lineLimit(2)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
        .minimumScaleFactor(0.2)
        .frame(maxWidth: 245 * 0.75, alignment: .center)
        .padding(.bottom)
    }
  }
  private var cardImage: some View {
    KFImage.url(card.highQualityImageURL)
      .onFailure { error in
        showError = true
        debugPrint(
          "🚩Error loading image from url: \(String(describing: card.highQualityImageURL)) with error: \(error)"
        )
      }
      .placeholder {
        placeholderImage
      }
      .resizable()
      .scaledToFit()
      .frame(width: imageCardWidth, height: imageCardHeight)
  }
}

#Preview {
  VStack {
    CardItemView(
      card: PokemonCard(
        id: "1",
        name: "Absol",
        image: "https://assets.tcgdex.net/en/pl/pl3/1/low.png"
      )
    )
  }
}
