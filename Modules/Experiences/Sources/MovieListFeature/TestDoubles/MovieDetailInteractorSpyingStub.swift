#if DEBUG
import MoviesDomainInterface

/// SpyingStub for `MovieDetailInteracting`: returns the configured result, records requested ids,
/// and can hold calls until `release()` so tests can observe in-flight states.
@MainActor
final class MovieDetailInteractorSpyingStub: MovieDetailInteracting {
    var detailsResultToBeReturned: Result<MovieDetails, any Error> = .success(.fixture())
    private(set) var requestedIDs: [Movie.ID] = []
    var holdsCalls = false
    private var held: [CheckedContinuation<Void, Never>] = []

    func release() {
        held.forEach { $0.resume() }
        held = []
    }

    /// Suspends until a held call is waiting. Pair with a test time limit.
    func waitUntilHeld() async {
        while held.isEmpty { await Task.yield() }
    }

    func details(id: Movie.ID) async throws -> MovieDetails {
        requestedIDs.append(id)
        if holdsCalls {
            await withCheckedContinuation { held.append($0) }
            // Like URLSession: a request whose task was cancelled while waiting fails with a cancellation.
            if Task.isCancelled { throw CancellationError() }
        }
        return try detailsResultToBeReturned.get()
    }
}
#endif
