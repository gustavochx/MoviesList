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
