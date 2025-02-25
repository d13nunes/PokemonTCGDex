import Kingfisher
import SwiftUI

struct CardItemView: View {
  let card: PokemonCard
  @State private var showError: Bool = false

  init(card: PokemonCard) {
    self.card = card
  }

  var body: some View {
    if showError {
      failureImage
    } else {
      CardImage(
        card: card,
        placeholderImage: placeholderImage
      )
    }
  }

  private var failureImage: some View {
    ZStack(alignment: .topTrailing) {
      placeholderImage
      Image(systemName: "exclamationmark.triangle")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(.red)
        .padding(.top, 8)
        .padding(.trailing, 8)
    }
    .aspectRatio(contentMode: .fit)
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
