import MoviesDomainInterface

/// Scene logic for the movie list: what to load and how to shape it for this screen.
/// The view model talks to this protocol; the interactor talks to the domain through its interface.
protocol MovieListInteracting: Sendable {
    func loadMovies() async throws -> [Movie]
}

struct MovieListInteractor: MovieListInteracting {
    private let service: MoviesService

    init(service: MoviesService) {
        self.service = service
    }

    func loadMovies() async throws -> [Movie] {
        try await service.all()
    }
}
