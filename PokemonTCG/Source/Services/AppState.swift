import Combine
import Foundation

@Observable
class AppState {
  let eventPublisher: PassthroughSubject<AppEvent, Never>
  var navigationPath: [AppRoute] = []
  private let apiClient: APIClient
  private var cancellables = Set<AnyCancellable>()

  init(
    apiClient: APIClient,
    eventPublisher: PassthroughSubject<AppEvent, Never> = PassthroughSubject<AppEvent, Never>()
  ) {
    self.apiClient = apiClient
    self.eventPublisher = eventPublisher
    self.setupEventHandling()
  }

  private func setupEventHandling() {
    eventPublisher
      .sink { [weak self] event in
        self?.processEvent(event: event)
      }
      .store(in: &cancellables)
  }

  private func processEvent(event: AppEvent) {
    switch event {
    case .showCardList:
      navigationPath = [.cardList]
    case .showCardDetails(let cardId):
      navigationPath = [.cardDetails(cardId: cardId)]
    case .navigateBack:
      navigationPath.removeLast()
    }
  }

}
