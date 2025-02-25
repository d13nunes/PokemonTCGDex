import Combine
import SwiftUI

struct CardListView: View {
  @State private var viewModel: CardListViewModel
  @State private var searchQuery: String = ""
  @State private var showNoResults: Bool = false
  @State private var isLoading: Bool = false
  @State private var isDisabled: Bool = false
  @FocusState private var isFocused: Bool

  init(viewModel: CardListViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    VStack {
      filterView
        .disabled(isDisabled)
        .padding(.horizontal)
      cardList
    }
    .overlay(showNoResults ? noResults : nil)
    .overlay {
      if let errorMessage = viewModel.errorMessage {
        ErrorView(
          message: errorMessage,
          onRetry: {
            viewModel.reloadAfterError()
          }
        )
      }
    }
    .overlay {
      if isLoading && viewModel.cards.isEmpty {
        ProgressView()
          .padding()
      }
    }
    .navigationTitle("Pokemon Cards")
    .searchable(text: $searchQuery, prompt: "Search by name...")
    .onChange(of: searchQuery) { oldValue, newValue in
      guard oldValue != newValue else { return }
      viewModel.requestQuery(query: newValue)
    }
    .onChange(of: viewModel.loadingState) { _, newValue in
      switch newValue {
      case .loaded:
        showNoResults = viewModel.cards.isEmpty && !searchQuery.isEmpty
        isLoading = false
        isDisabled = showNoResults
      case .loading:
        isLoading = true
        isDisabled = true
        showNoResults = false
      case .error, .idle:
        isLoading = false
        isDisabled = false
        showNoResults = false
      }
    }
    .onAppear {
      viewModel.onViewAppeared()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isFocused = true
        isFocused = false
      }
    }
  }

  private var noResults: some View {
    Text("No results found for \"\(searchQuery)\"")
      .font(.headline)
      .padding()
  }

  private var cardList: some View {
    ScrollView {
      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible()), count: 4),
        spacing: 2
      ) {
        ForEach(viewModel.cards) { card in
          CardItemView(card: card)
            .onTapGesture {
              viewModel.onCardSelected(card: card)
            }
            .onAppear {
              if card == viewModel.cards.last && viewModel.hasMorePages {
                viewModel.loadMoreCards()
              }
            }
        }
      }
      .padding()
      if isLoading && !viewModel.cards.isEmpty {
        ProgressView()
          .padding()
      }
    }
  }

  private var filterView: some View {
    HStack {
      Picker("Sort by", selection: $viewModel.selectedSortField) {
        ForEach(viewModel.availableSortFields, id: \.self) { field in
          Text(field.rawValue.capitalized)
        }
      }
      .pickerStyle(.segmented)
      Picker("Sort order", selection: $viewModel.selectedSortOrder) {
        ForEach(viewModel.availableSortOrders, id: \.self) { order in
          Text(order.rawValue.capitalized)
        }
      }
      .pickerStyle(.segmented)
    }
  }
}

#Preview {
  CardListView(
    viewModel: CardListViewModel(
      apiClient: TCGDexAPIClient(),
      eventPublisher: PassthroughSubject<AppEvent, Never>()
    )
  )
}
