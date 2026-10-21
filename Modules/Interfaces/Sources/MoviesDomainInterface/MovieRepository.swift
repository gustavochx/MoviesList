import Foundation

/// Where Movie values are stored. Implemented by a data module (e.g. MoviesData);
/// until one exists, the app's composition root supplies an in-memory implementation.
public protocol MovieRepository: Sendable {
    func all() async throws -> [Movie]
    func save(_ item: Movie) async throws
}
