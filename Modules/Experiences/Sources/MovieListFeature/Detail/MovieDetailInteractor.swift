import MoviesDomainInterface

/// Scene logic for the movie detail screen. Depends only on the domain contract, so this folder
/// can move to its own feature module without touching the list.
protocol MovieDetailInteracting: Sendable {
    func details(id: Movie.ID) async throws -> MovieDetails
}

struct MovieDetailInteractor: MovieDetailInteracting {
    private let service: MoviesService

    init(service: MoviesService) {
        self.service = service
    }

    func details(id: Movie.ID) async throws -> MovieDetails {
        try await service.details(id: id)
    }
}
