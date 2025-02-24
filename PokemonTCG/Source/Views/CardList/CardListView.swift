import Combine
import SwiftUI

struct CardListView: View {
  @State private var viewModel: CardListViewModel
  @State private var searchQuery: String = ""

  private var showNoResults: Bool {
    switch viewModel.loadingState {
    case .loaded:
      return viewModel.cards.isEmpty && !searchQuery.isEmpty
    default:
      return false
    }
  }

  init(viewModel: CardListViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        VStack {
          filterView
          cardList
        }

        if viewModel.showFullScreenLoading {
          ProgressView {
            Text("Loading...")
          }
          .colorInvert()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
      .navigationTitle("Pokemon Cards")
      .searchable(text: $searchQuery, prompt: "Search by name...")
      .onChange(of: searchQuery) { oldValue, newValue in
        guard oldValue != newValue else { return }
        viewModel.requestQuery(query: newValue)
      }
    }
    .onAppear {
      viewModel.onViewAppeared()
    }
  }

  private var noResults: some View {
    Text("No results found")
      .font(.headline)
      .padding()
  }
  private var cardList: some View {
    ScrollView {
      LazyVGrid(
        columns: Array(repeating: GridItem(.fixed(90)), count: 4),
        spacing: 2
      ) {
        ForEach(viewModel.cards) { card in
          CardItemView(card: card, width: 90, height: 130)
            .onTapGesture {
              viewModel.onCardSelected(cardId: card.id)
            }
            .onAppear {
              if card == viewModel.cards.last && viewModel.hasMorePages {
                viewModel.loadMoreCards()
              }
            }
        }
      }
      .padding()

      if viewModel.loadingState == .loading && !viewModel.cards.isEmpty {
        ProgressView()
          .padding()
      }
    }
    .refreshable {
      viewModel.onRefresh()
    }
  }

  private var sortPicker: some View {
    Picker("Sort by", selection: $viewModel.selectedSortField) {
      ForEach(viewModel.availableSortFields, id: \.self) { field in
        Text(field.rawValue.capitalized)
      }
    }
    .pickerStyle(.segmented)
  }

  private var sortOrderPicker: some View {
    Picker("Sort order", selection: $viewModel.selectedSortOrder) {
      ForEach(viewModel.availableSortOrders, id: \.self) { order in
        Text(order.rawValue.capitalized)
      }
    }
    .pickerStyle(.segmented)
  }

  private var filterView: some View {
    HStack {
      sortPicker
      sortOrderPicker
    }
    .disabled(viewModel.loadingState == .loading)
    .padding(.horizontal, 24)
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
