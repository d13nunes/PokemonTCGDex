import Combine
import SwiftUI

struct CardListView: View {
  @State private var viewModel: CardListViewModel
  @State private var searchQuery: String = ""
  @State private var showNoResults: Bool = false
  @State private var isLoading: Bool = false

  init(viewModel: CardListViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    VStack {
      filterView
      searchbar
      cardList
    }
    .padding(.horizontal)
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
    .onChange(of: viewModel.loadingState) { _, newValue in
      switch newValue {
      case .loaded:
        showNoResults = viewModel.cards.isEmpty && !searchQuery.isEmpty
        isLoading = false
      case .loading:
        isLoading = true
        showNoResults = false
      case .error, .idle:
        isLoading = false
        showNoResults = false
      }
    }
    .onAppear {
      viewModel.onViewAppeared()
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
        ForEach(viewModel.cards.indices, id: \.self) { index in
          CardItemView(card: viewModel.cards[index])
            .onTapGesture {
              viewModel.onCardSelected(card: viewModel.cards[index])
            }
            .onAppear {
              let percentage = Double(index) / Double(viewModel.cards.count)
              if percentage > 0.6 && viewModel.hasMorePages {
                viewModel.loadMoreCards()
              }
            }
        }
      }
      if isLoading && !viewModel.cards.isEmpty {
        ProgressView()
          .padding()
      }
    }
    .scrollDismissesKeyboard(.immediately)
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

  private var searchbar: some View {
    SearchBar(
      text: $searchQuery,
      onTextChanged: { query in
        viewModel.requestQuery(query: query)
      }
    )
    .submitLabel(.search)
    .autocapitalization(.none)
    .autocorrectionDisabled()
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
