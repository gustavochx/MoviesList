import MoviesDomainInterface

/// Scene logic for the movie list: which movies to show for the current search text.
/// The view model talks to this protocol; the interactor talks to the domain through its interface.
protocol MovieListInteracting: Sendable {
    /// Search results for `query`; the domain returns popular movies for a blank one.
    func movies(matching query: String, page: Int) async throws -> MoviesPage
}

struct MovieListInteractor: MovieListInteracting {
    private let service: MoviesService

    init(service: MoviesService) {
        self.service = service
    }

    func movies(matching query: String, page: Int) async throws -> MoviesPage {
        try await service.search(query, page: page)
    }
}
