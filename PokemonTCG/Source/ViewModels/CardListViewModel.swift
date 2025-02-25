import Combine
import Foundation

@MainActor
@Observable
class CardListViewModel {

  private(set) var cards: [PokemonCard] = []
  private(set) var loadingState: LoadingState = .idle
  private(set) var errorMessage: String?
  private(set) var currentPage: Int = 1
  private(set) var hasMorePages: Bool = false

  var availableSortFields: [SortField] = SortField.allCases
  var availableSortOrders: [SortOrder] = SortOrder.allCases
  var selectedSortField: SortField
  {
    didSet {
      fetchCards(query: searchQuery)
    }
  }
  var selectedSortOrder: SortOrder
  {
    didSet {
      fetchCards(query: searchQuery)
    }
  }
  private var searchQuery: String = ""
  private var currentSortField: SortField
  private var currentSortOrder: SortOrder

  private let queryRequestPublisher = PassthroughSubject<String, Never>()
  private let pageSize: Int

  private let apiClient: APIClient
  private let eventPublisher: PassthroughSubject<AppEvent, Never>
  private var cancellables = Set<AnyCancellable>()

  init(
    apiClient: APIClient,
    eventPublisher: PassthroughSubject<AppEvent, Never>,
    pageSize: Int = 40
  ) {
    self.apiClient = apiClient
    self.eventPublisher = eventPublisher
    self.pageSize = pageSize

    let defaultSortField: SortField = .name
    self.selectedSortField = defaultSortField
    self.currentSortField = defaultSortField

    let defaultSortOrder: SortOrder = .asc
    self.selectedSortOrder = defaultSortOrder
    self.currentSortOrder = defaultSortOrder

    queryRequestPublisher
      .removeDuplicates()
      .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
      .sink { [weak self] query in
        self?.fetchCards(query: query)
      }
      .store(in: &cancellables)
  }

  func requestQuery(query: String) {
    queryRequestPublisher.send(query)
  }

  func onViewAppeared() {
    if case .idle = loadingState, cards.isEmpty {
      fetchCards(query: searchQuery)
    }
  }

  func reloadAfterError() {
    fetchCards(query: searchQuery)
  }

  func onRefresh() {
    fetchCards(query: searchQuery)
  }

  func loadMoreCards() {
    if hasMorePages {
      fetchCards(query: searchQuery, loadMore: true)
    }
  }

  func onCardSelected(card: PokemonCard) {
    eventPublisher.send(.showCardDetails(card: card))
  }

  private func canFetchCards(query: String, loadMore: Bool) -> Bool {
    switch loadingState {
    case .loading:
      return false
    case .idle, .error:
      return true
    case .loaded:
      return loadMore
        || self.searchQuery != query
        || self.currentSortField != selectedSortField
        || self.currentSortOrder != selectedSortOrder
    }
  }
  private func fetchCards(query: String, loadMore: Bool = false) {
    guard canFetchCards(query: query, loadMore: loadMore) else { return }
    self.loadingState = .loading
    self.errorMessage = nil
    if !loadMore {
      self.cards = []
      self.currentPage = 1
      self.hasMorePages = true
    }
    let nextPage = loadMore ? currentPage + 1 : 1
    Task {
      do {
        let cards = try await apiClient.fetchCards(
          query: query,
          pagination: PaginationRequest(page: nextPage, itemsPerPage: pageSize),
          sortField: selectedSortField,
          sortOrder: selectedSortOrder
        )
        if loadMore {
          self.cards.append(contentsOf: cards.items)
        } else {
          self.cards = cards.items
        }
        self.currentPage = nextPage
        self.hasMorePages = cards.items.count == pageSize
        self.loadingState = .loaded
        self.searchQuery = query
        self.currentSortField = selectedSortField
        self.currentSortOrder = selectedSortOrder
      } catch {
        self.errorMessage = error.localizedDescription
        self.loadingState = .error(error)
      }
    }
  }
}
