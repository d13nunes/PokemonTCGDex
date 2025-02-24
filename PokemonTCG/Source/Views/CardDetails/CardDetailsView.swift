import SwiftUI

struct CardDetailsView: View {
  let cardId: String
  private var appState: AppState

  init(cardId: String, appState: AppState) {
    self.cardId = cardId
    self.appState = appState
  }

  var body: some View {
    VStack {
      Text("Card Details: \(cardId)")
      Button("Back") {
        appState.eventPublisher.send(.navigateBack)
      }
    }
  }
}
