import Foundation

/// What the rest of the app can ask of the Movies domain. Implemented by LiveMoviesService.
public protocol MoviesService: Sendable {
    func all() async throws -> [Movie]
}
