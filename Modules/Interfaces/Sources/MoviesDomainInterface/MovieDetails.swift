import Foundation

/// Everything the detail screen shows about one movie.
public struct MovieDetails: Identifiable, Hashable, Sendable {
    public let id: Movie.ID
    public let title: String
    public let tagline: String?
    public let overview: String
    public let releaseDate: Date?
    public let runtimeMinutes: Int?
    public let genres: [String]
    /// Average user rating, from 0 to 10.
    public let rating: Double
    public let voteCount: Int
    public let posterURL: URL?
    public let backdropURL: URL?
    /// Top-billed cast, in billing order.
    public let cast: [CastMember]

    public init(
        id: Movie.ID,
        title: String,
        tagline: String?,
        overview: String,
        releaseDate: Date?,
        runtimeMinutes: Int?,
        genres: [String],
        rating: Double,
        voteCount: Int,
        posterURL: URL?,
        backdropURL: URL?,
        cast: [CastMember]
    ) {
        self.id = id
        self.title = title
        self.tagline = tagline
        self.overview = overview
        self.releaseDate = releaseDate
        self.runtimeMinutes = runtimeMinutes
        self.genres = genres
        self.rating = rating
        self.voteCount = voteCount
        self.posterURL = posterURL
        self.backdropURL = backdropURL
        self.cast = cast
    }
}

public struct CastMember: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let character: String
    public let profileURL: URL?

    public init(id: Int, name: String, character: String, profileURL: URL?) {
        self.id = id
        self.name = name
        self.character = character
        self.profileURL = profileURL
    }
}

#if DEBUG
extension MovieDetails {
    /// A representative movie detail for tests and previews. Override only what a test cares about.
    public static func fixture(
        id: Movie.ID = 1,
        title: String = "Dune: Part Two",
        tagline: String? = "Long live the fighters.",
        overview: String = "Paul Atreides unites with Chani and the Fremen.",
        releaseDate: Date? = Date(timeIntervalSince1970: 1_708_992_000), // 2024-02-27 UTC
        runtimeMinutes: Int? = 166,
        genres: [String] = ["Science Fiction", "Adventure"],
        rating: Double = 8.2,
        voteCount: Int = 6_400,
        posterURL: URL? = nil,
        backdropURL: URL? = nil,
        cast: [CastMember] = [.fixture()]
    ) -> MovieDetails {
        MovieDetails(
            id: id, title: title, tagline: tagline, overview: overview, releaseDate: releaseDate,
            runtimeMinutes: runtimeMinutes, genres: genres, rating: rating, voteCount: voteCount,
            posterURL: posterURL, backdropURL: backdropURL, cast: cast
        )
    }
}

extension CastMember {
    public static func fixture(
        id: Int = 1,
        name: String = "Timothée Chalamet",
        character: String = "Paul Atreides",
        profileURL: URL? = nil
    ) -> CastMember {
        CastMember(id: id, name: name, character: character, profileURL: profileURL)
    }
}
#endif
