import MoviesDomainInterface

/// Live implementation of `MoviesService`. Only the composition root and tests should import this module.
public final class LiveMoviesService: MoviesService {
    private let repository: MovieRepository

    public init(repository: MovieRepository) {
        self.repository = repository
    }

    public func popular(page: Int) async throws -> MoviesPage {
        try await repository.popular(page: page).withoutUntitledMovies()
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return try await popular(page: page) }
        return try await repository.search(query, page: page).withoutUntitledMovies()
    }
}

private extension MoviesPage {
    /// Movies without a title can't be shown or searched for, so the domain drops them.
    func withoutUntitledMovies() -> MoviesPage {
        MoviesPage(
            movies: movies.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            page: page,
            totalPages: totalPages
        )
    }
}
