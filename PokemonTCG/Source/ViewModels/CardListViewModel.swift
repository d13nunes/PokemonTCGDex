import Combine
import Foundation

@MainActor
@Observable
class CardListViewModel {
  // Published properties for the View to observe
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
      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
      .sink { [weak self] query in
        self?.fetchCards(query: query)
      }
      .store(in: &cancellables)
  }

  func requestQuery(query: String) {
    queryRequestPublisher.send(query)
  }

  // MARK: - Public Methods

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
      fetchNextPage(query: searchQuery)
    }
  }

  func onCardSelected(card: PokemonCard) {
    eventPublisher.send(.showCardDetails(card: card))
  }

  private func canFetchCards(query: String, loadMore: Bool = false) -> Bool {
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
  private func fetchCards(query: String) {
    guard canFetchCards(query: query) else { return }
    self.loadingState = .loading
    self.errorMessage = nil
    self.cards = []
    self.currentPage = 1
    self.hasMorePages = true
    Task {
      do {
        let cards = try await apiClient.fetchCards(
          query: query,
          pagination: PaginationRequest(page: currentPage, itemsPerPage: pageSize),
          sortField: selectedSortField,
          sortOrder: selectedSortOrder
        )
        self.cards = cards.items
        self.currentPage = 1
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

  private func fetchNextPage(query: String) {
    guard canFetchCards(query: query, loadMore: true) else { return }
    self.loadingState = .loading
    self.errorMessage = nil

    Task {
      do {
        let cards = try await apiClient.fetchCards(
          query: query,
          pagination: PaginationRequest(page: currentPage + 1, itemsPerPage: pageSize),
          sortField: selectedSortField,
          sortOrder: selectedSortOrder
        )
        self.cards.append(contentsOf: cards.items)
        self.currentPage += 1
        self.hasMorePages = cards.items.count == pageSize
        self.loadingState = .loaded
        self.searchQuery = query
        self.currentSortField = selectedSortField
        self.currentSortOrder = selectedSortOrder
      } catch {
        // TODO: Improve error handling on loading more cards
        self.errorMessage = error.localizedDescription
        self.loadingState = .error(error)
      }
    }
  }

}
