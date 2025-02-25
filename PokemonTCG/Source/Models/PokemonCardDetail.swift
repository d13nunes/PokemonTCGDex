import Foundation

// Base card structure with common properties
struct CardDetail: Codable {
  let category: String
  let id: String
  let illustrator: String?
  let image: String?
  let localId: String
  let name: String
  let rarity: String?
  let set: CardSet
  let variants: CardVariants

  let legal: Legal?
  let description: String?

  var pokemon: PokemonCardDetail?
  var trainer: TrainerCardDetail?
  var energy: EnergyCardDetail?

  // Common nested types
  struct CardSet: Codable {
    let cardCount: CardCount
    let id: String
    let logo: String?
    let name: String
    let symbol: String?

    struct CardCount: Codable {
      let official: Int
      let total: Int
    }

    var logoURL: URL? {
      guard let logo = logo else { return nil }
      return getImageURL(image: logo, imageExtension: .webp)
    }

    var symbolURL: URL? {
      guard let symbol = symbol else { return nil }
      return getImageURL(image: symbol, imageExtension: .webp)
    }

    private func getImageURL(image: String, imageExtension: ImageExtension) -> URL? {
      let absoluteURLString = "\(image).\(imageExtension.rawValue)"
      return URL(string: absoluteURLString)
    }
  }

  struct CardVariants: Codable {
    let firstEdition: Bool
    let holo: Bool
    let normal: Bool
    let reverse: Bool
    let wPromo: Bool

    func toString() -> String {
      var variants = [String]()
      if firstEdition {
        variants.append("First Edition")
      }
      if holo {
        variants.append("Holo")
      }
      if normal {
        variants.append("Normal")
      }
      if reverse {
        variants.append("Reverse")
      }
      if wPromo {
        variants.append("W Promo")
      }
      return variants.joined(separator: ", ")
    }
  }

  struct Legal: Codable {
    let standard: Bool
    let expanded: Bool

    func toString() -> String {
      var legalities = [String]()
      if standard {
        legalities.append("Standard")
      }
      if expanded {
        legalities.append("Expanded")
      }
      if legalities.isEmpty {
        return "none"
      }
      return legalities.joined(separator: ", ")
    }
  }

}

// Pokemon specific card
struct PokemonCardDetail: Codable {
  let dexId: [Int]?
  let hp: Int?
  let types: [String]?
  let evolveFrom: String?
  let stage: String?
  let level: String?
  let suffix: String?
  let attacks: [Attack]?
  let weaknesses: [Weakness]?
  let retreat: Int?
  let abilities: [Ability]?

  struct Ability: Codable {
    let name: String
    let type: String
    let effect: String
  }

  struct Attack: Codable {
    let name: String
    let cost: [String]
    let damage: String?
    let effect: String?

    enum CodingKeys: String, CodingKey {
      case name, cost, damage, effect
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      name = try container.decode(String.self, forKey: .name)
      cost = try container.decodeIfPresent([String].self, forKey: .cost) ?? []
      effect = try container.decodeIfPresent(String.self, forKey: .effect)

      // Handle damage that could be either Int or String
      if let damageInt = try? container.decodeIfPresent(Int.self, forKey: .damage) {
        damage = String(damageInt)
      } else {
        damage = try container.decodeIfPresent(String.self, forKey: .damage)
      }
    }
  }

  struct Weakness: Codable {
    let type: String
    let value: String
  }
}

// Trainer specific card
struct TrainerCardDetail: Codable {
  let effect: String?
  let trainerType: String?  // e.g., "Supporter
}

// Energy specific card
struct EnergyCardDetail: Codable {
  let effect: String?
  let energyType: String
}

// Factory to create the appropriate card type
enum CardDetailFactory {
  static func createCard(data: Data) throws -> CardDetail {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    var cardDetail = try decoder.decode(CardDetail.self, from: data)

    switch cardDetail.category.lowercased() {
    case "pokemon":
      cardDetail.pokemon = try decoder.decode(PokemonCardDetail.self, from: data)
    case "trainer":
      cardDetail.trainer = try decoder.decode(TrainerCardDetail.self, from: data)
    case "energy":
      cardDetail.energy = try decoder.decode(EnergyCardDetail.self, from: data)
    default:
      print("❌ CardDetailFactory: createCard: Invalid category type")
      throw DecodingError.keyNotFound(
        CodingKeys.category,
        DecodingError.Context(codingPath: [], debugDescription: "Invalid category type")
      )
    }
    return cardDetail
  }

  private enum CodingKeys: String, CodingKey {
    case category
  }
}
