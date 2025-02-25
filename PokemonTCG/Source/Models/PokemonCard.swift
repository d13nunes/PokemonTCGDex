import Foundation

struct PokemonCard: Codable, Identifiable, Equatable, Hashable {
  let id: String
  let name: String
  let image: String?

  static func == (lhs: PokemonCard, rhs: PokemonCard) -> Bool {
    return lhs.id == rhs.id
  }

  enum CodingKeys: String, CodingKey {
    case id, name, image
  }

  var highQualityImageURL: URL? {
    return getImageURL(quality: .high, imageExtension: .webp)
  }

  var lowQualityImageURL: URL? {
    return getImageURL(quality: .low, imageExtension: .webp)
  }

  func getImageURL(quality: ImageQuality, imageExtension: ImageExtension) -> URL? {
    guard let image = image else { return nil }
    let absoluteURLString = "\(image)/\(quality.rawValue).\(imageExtension.rawValue)"
    return URL(string: absoluteURLString)
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

enum ImageQuality: String {
  case high
  case low
}

enum ImageExtension: String {
  case png
  case jpg
  case webp
}
