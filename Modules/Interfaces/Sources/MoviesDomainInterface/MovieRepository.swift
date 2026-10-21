/// Where movies come from. Implemented by a data module (`MoviesData` for TMDB).
public protocol MovieRepository: Sendable {
    func popular(page: Int) async throws -> MoviesPage
    func search(_ query: String, page: Int) async throws -> MoviesPage
    func details(id: Movie.ID) async throws -> MovieDetails
}
