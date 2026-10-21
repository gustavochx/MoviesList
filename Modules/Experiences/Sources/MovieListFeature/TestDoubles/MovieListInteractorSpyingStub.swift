#if DEBUG
import MoviesDomainInterface

/// SpyingStub for `MovieListInteracting`: answers per query and page, records every call,
/// and can hold one query until `release()` so tests can observe in-flight states.
@MainActor
final class MovieListInteractorSpyingStub: MovieListInteracting {
    struct Call: Hashable {
        let query: String
        let page: Int
    }

    /// Unconfigured calls return an empty last page.
    var resultsToBeReturned: [Call: Result<MoviesPage, any Error>] = [:]
    private(set) var calls: [Call] = []
    private var heldQuery: String?
    private var held: [CheckedContinuation<Void, Never>] = []

    var heldCallCount: Int { held.count }

    func respond(to query: String = "", page: Int = 1, with result: Result<MoviesPage, any Error>) {
        resultsToBeReturned[Call(query: query, page: page)] = result
    }

    func hold(query: String?) {
        heldQuery = query
    }

    func release() {
        held.forEach { $0.resume() }
        held = []
    }

    /// Suspends until a held call is waiting. Pair with a test time limit.
    func waitUntilHeld() async {
        while held.isEmpty { await Task.yield() }
    }

    func movies(matching query: String, page: Int) async throws -> MoviesPage {
        let call = Call(query: query, page: page)
        calls.append(call)
        if query == heldQuery {
            await withCheckedContinuation { held.append($0) }
            // Like URLSession: a request whose task was cancelled while waiting fails with a cancellation.
            if Task.isCancelled { throw CancellationError() }
        }
        return try (resultsToBeReturned[call] ?? .success(.fixture(movies: [], page: page, totalPages: page))).get()
    }
}
#endif
