/// Why movies couldn't be loaded, in terms the presentation layer can act on.
public enum MoviesError: Error, Equatable, Sendable {
    /// No network connection.
    case offline
    /// The API key is missing or was rejected.
    case unauthorized
    /// Anything else: server errors, unexpected responses.
    case unavailable
}
