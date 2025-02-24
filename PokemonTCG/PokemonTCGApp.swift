//
//  PokemonTCGApp.swift
//  PokemonTCG
//
//  Created by Diogo Nunes on 24/02/2025.
//

import Combine
import SwiftUI

@main
struct PokemonTCGApp: App {
  private let apiClient: APIClient
  let cardListViewModel: CardListViewModel

  @State var appState: AppState

  init() {

    self.apiClient = TCGDexAPIClient()
    let appState = AppState(
      apiClient: apiClient
    )

    cardListViewModel = CardListViewModel(
      apiClient: apiClient,
      eventPublisher: appState.eventPublisher
    )

    self.appState = appState

  }

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: $appState.navigationPath) {
        CardListView(viewModel: cardListViewModel)
          .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .cardList:
              CardListView(viewModel: cardListViewModel)
            case .cardDetails(let cardId):
              Text("Card Details: \(cardId)")
              Button("Back") {
                appState.eventPublisher.send(.navigateBack)
              }
            }
          }
      }
    }
  }

}
