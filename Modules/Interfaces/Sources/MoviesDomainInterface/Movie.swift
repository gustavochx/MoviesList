import Foundation

/// A movie as the rest of the app sees it, independent of where it came from.
public struct Movie: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let releaseDate: Date?
    /// Average user rating, from 0 to 10.
    public let rating: Double
    public let posterURL: URL?

    public init(id: Int, title: String, releaseDate: Date?, rating: Double, posterURL: URL?) {
        self.id = id
        self.title = title
        self.releaseDate = releaseDate
        self.rating = rating
        self.posterURL = posterURL
    }
}

#if DEBUG
extension Movie {
    /// A representative movie for tests and previews. Override only what a test cares about.
    public static func fixture(
        id: Int = 1,
        title: String = "Dune: Part Two",
        releaseDate: Date? = Date(timeIntervalSince1970: 1_708_992_000), // 2024-02-27 UTC
        rating: Double = 8.2,
        posterURL: URL? = nil
    ) -> Movie {
        Movie(id: id, title: title, releaseDate: releaseDate, rating: rating, posterURL: posterURL)
    }
}
#endif
