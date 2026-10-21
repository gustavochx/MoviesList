import Foundation
import MoviesDomainInterface

/// Live implementation of `MoviesService`. Only the composition root and tests should import this module.
public final class LiveMoviesService: MoviesService {
    private let repository: MovieRepository

    public init(repository: MovieRepository) {
        self.repository = repository
    }

    /// Newest first.
    public func all() async throws -> [Movie] {
        try await repository.all().sorted { $0.createdAt > $1.createdAt }
    }
}
