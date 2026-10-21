/// What the rest of the app can ask of the Movies domain. Implemented by `LiveMoviesService`.
/// Methods throw `MoviesError`.
public protocol MoviesService: Sendable {
    func popular(page: Int) async throws -> MoviesPage
    /// A blank query returns the popular movies.
    func search(_ query: String, page: Int) async throws -> MoviesPage
}
