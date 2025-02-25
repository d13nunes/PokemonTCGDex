import Kingfisher
import SwiftUI

struct CardDetailsView: View {
  @State private var viewModel: CardDetailsViewModel
  @State private var isLoading: Bool = false

  init(viewModel: CardDetailsViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Card Image
        CardImage(
          card: viewModel.card,
          placeholderImage: ProgressView()
        )
        if viewModel.loadingState == .loading {
          ProgressView()
        }
        if case .error(let error) = viewModel.loadingState {
          ErrorView(
            message: error.localizedDescription,
            onRetry: {
              viewModel.reloadAfterError()
            }
          )
        }
        if let info = viewModel.commonInformation {
          commonInformation(info)
        }
        if let info = viewModel.pokemonInformation {
          pokemonInformation(info)
        }
        if let info = viewModel.trainerInformation {
          trainerInformation(info)
        }
        if let info = viewModel.energyInformation {
          energyInformation(info)
        }
      }
      .padding()
    }
    .onAppear {
      viewModel.onViewAppeared()
    }
    .onChange(of: viewModel.loadingState) { oldValue, newValue in
      print("loadingState: \(oldValue) -> \(newValue)")
      switch newValue {
      case .loading:
        isLoading = true
      case .idle, .error, .loaded:
        isLoading = false
      }
    }
    .navigationTitle(viewModel.cardName)
  }

  private func commonInformation(_ commonInformation: CardDetail) -> some View {
    return VStack {
      DetailRow(label: "Name", content: Text(commonInformation.name))
      DetailRow(label: "Card Category", content: Text(commonInformation.category))
      if let rarity = commonInformation.rarity {
        DetailRow(label: "Rarity", content: Text(rarity))
      }
      if let illustrator = commonInformation.illustrator {
        DetailRow(label: "Ilustrator", content: Text(illustrator))
      }
      DetailRow(
        label: "Variants",
        content: Text(commonInformation.variants.toString())
      )
      if let legal = commonInformation.legal {
        DetailRow(label: "Legal in", content: Text(legal.toString()))
      }
      if let set = viewModel.commonInformation?.set {
        DetailRow(
          label: "Set",
          content: HStack {
            KFImage(set.logoURL)
              .resizable()
              .scaledToFit()
              .frame(height: 40)
          }
        )
      }
    }
  }

  private func pokemonInformation(_ pokemonInformation: PokemonCardDetail) -> some View {
    return VStack {
      if let dexId = pokemonInformation.dexId {
        DetailRow(
          label: "Dex Number",
          content: Text(dexId.map { String($0) }.joined(separator: ", "))
        )
      }
      if let types = pokemonInformation.types {
        DetailRow(
          label: "Pokemon Type(s)",
          content: Text(types.joined(separator: ", "))
        )
      }
      if let hp = pokemonInformation.hp {
        DetailRow(label: "Pokemon HP", content: Text(String(hp)))
      }
      if let weaknesses = pokemonInformation.weaknesses {
        DetailRow(
          label: "Pokemon Weakness",
          content: Text(weaknesses.map { $0.type }.joined(separator: ", "))
        )
      }
      if let retreat = pokemonInformation.retreat {
        DetailRow(label: "Pokemon Retreat", content: Text(String(retreat)))
      }
      if let level = pokemonInformation.level {
        DetailRow(label: "Level", content: Text(level))
      }
      if let stage = pokemonInformation.stage {
        DetailRow(label: "Stage", content: Text(stage))
      }
      if let evolveFrom = pokemonInformation.evolveFrom {
        DetailRow(label: "Evolve From", content: Text(evolveFrom))
      }
      if let attacks = pokemonInformation.attacks {
        VStack {
          Text("Attacks")
            .fontWeight(.bold)
            .padding(.top, 12)
          ForEach(attacks, id: \.name) { attack in
            DetailRow(
              label: "Attack",
              content: Text(attack.name)
                .fontWeight(.bold)
            )
            .padding(.top, 6)
            if let damage = attack.damage {
              DetailRow(label: "Damage", content: Text(damage))
            }
            if let effect = attack.effect {
              DetailRow(label: "Effect", content: Text(effect))
            }
            DetailRow(label: "Cost", content: Text(attack.cost.map { $0 }.joined(separator: ", ")))
          }
        }
      }
      if let abilities = pokemonInformation.abilities {
        VStack {
          Text("Abilities")
            .fontWeight(.bold)
            .padding(.top, 12)
          ForEach(abilities, id: \.name) { ability in
            DetailRow(
              label: "Ability",
              content: Text(ability.name)
                .fontWeight(.bold)
            )
            .padding(.top, 6)
            DetailRow(label: "Type", content: Text(ability.type))
            DetailRow(label: "Effect", content: Text(ability.effect))
          }
        }
      }
    }
  }

  private func trainerInformation(_ trainerInformation: TrainerCardDetail) -> some View {
    return VStack {
      if let effect = trainerInformation.effect {
        Text("Effect")
          .fontWeight(.bold)
          .padding(.top, 12)
        Text(effect)
      }
    }
  }

  private func energyInformation(_ energyInformation: EnergyCardDetail) -> some View {
    VStack {
      if let effect = energyInformation.effect {
        Text("Effect")
          .fontWeight(.bold)
          .padding(.top, 12)
        Text(effect)
      }
      DetailRow(label: "Energy Type", content: Text(energyInformation.energyType))

    }
  }
}

private struct DetailRow<Content: View>: View {
  let label: String
  let content: Content

  var body: some View {
    HStack(alignment: .top) {
      Text(label)
        .fontWeight(.bold)
      Spacer()
      content
    }
  }
}

#Preview {
  let pokemon = PokemonCard(
    id: "xy12-9",
    name: "Charmander",
    image: "https://assets.tcgdex.net/en/xy/xy12/9"
  )
  let trainerCard1 = PokemonCard(
    id: "bw7-140",
    name: "Gold Potion",
    image: "https://assets.tcgdex.net/en/bw/bw7/140"
  )

  let trainerCard2 = PokemonCard(
    id: "base4-102",
    name: "Impostor Professor Oak",
    image: "https://assets.tcgdex.net/en/base/base4/102"
  )

  let energyCard = PokemonCard(
    id: "bw6-117",
    name: "Blend Energy Grass Fire Psychic Darkness",
    image: "https://assets.tcgdex.net/en/bw/bw6/117"
  )

  // let card = pokemon
  let card = energyCard
  NavigationStack {
    CardDetailsView(viewModel: CardDetailsViewModel(apiClient: TCGDexAPIClient(), card: card))
  }
}
