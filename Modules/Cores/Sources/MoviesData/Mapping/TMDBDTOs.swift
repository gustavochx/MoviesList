/// TMDB's paginated list response (`/movie/popular`, `/search/movie`).
struct TMDBPageDTO: Decodable, Sendable {
    let page: Int
    let results: [TMDBMovieDTO]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}

struct TMDBMovieDTO: Decodable, Sendable {
    let id: Int
    let title: String
    /// "YYYY-MM-DD", or an empty string when unknown.
    let releaseDate: String?
    let voteAverage: Double?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
    }
}

/// `/movie/{id}?append_to_response=credits`.
struct TMDBMovieDetailsDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let tagline: String?
    let overview: String?
    let releaseDate: String?
    /// Minutes; TMDB sends 0 or null when unknown.
    let runtime: Int?
    let genres: [Genre]?
    let voteAverage: Double?
    let voteCount: Int?
    let posterPath: String?
    let backdropPath: String?
    let credits: Credits?

    struct Genre: Decodable, Sendable {
        let name: String
    }

    struct Credits: Decodable, Sendable {
        let cast: [Cast]
    }

    struct Cast: Decodable, Sendable {
        let id: Int
        let name: String
        let character: String?
        let profilePath: String?

        enum CodingKeys: String, CodingKey {
            case id, name, character
            case profilePath = "profile_path"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, tagline, overview, runtime, genres, credits
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}
