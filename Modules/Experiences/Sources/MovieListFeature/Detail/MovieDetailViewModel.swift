import Foundation
import MoviesDomainInterface
import Observation

@MainActor
@Observable
final class MovieDetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(MovieDetailModel)
        case notFound
        case failed(LoadFailure)
    }

    let movieID: Movie.ID
    private(set) var state: State = .loading

    @ObservationIgnored private let interactor: MovieDetailInteracting
    /// Bumped on every request so a slower, older response can't overwrite a newer one.
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var isLoading = false
    /// Callers of `load()` waiting for the request in flight to end.
    @ObservationIgnored private var loadWaiters: [CheckedContinuation<Void, Never>] = []

    init(movieID: Movie.ID, interactor: MovieDetailInteracting) {
        self.movieID = movieID
        self.interactor = interactor
    }

    /// The title once loaded, for the navigation bar.
    var title: String {
        if case let .loaded(model) = state { model.title } else { "" }
    }

    /// First load. Does nothing once loaded. While a request is in flight it waits for that request
    /// instead of starting another, and loads again only if the request ended without a result
    /// (for example, it was cancelled because the screen briefly went away).
    func load() async {
        while isLoading {
            await withCheckedContinuation { loadWaiters.append($0) }
        }
        guard state == .loading, !Task.isCancelled else { return }
        await fetch()
    }

    func retry() async {
        state = .loading
        await fetch()
    }
}

// MARK: Private helpers
private extension MovieDetailViewModel {
    func fetch() async {
        generation += 1
        let current = generation
        isLoading = true
        defer {
            if current == generation {
                isLoading = false
                resumeLoadWaiters()
            }
        }
        do {
            let details = try await interactor.details(id: movieID)
            guard current == generation else { return }
            state = .loaded(MovieDetailModel(details: details))
        } catch {
            // A cancelled task (the user went back) is not a failure to show.
            guard current == generation, !(error is CancellationError), !Task.isCancelled else { return }
            state = (error as? MoviesError) == .notFound ? .notFound : .failed(LoadFailure(error))
        }
    }

    func resumeLoadWaiters() {
        let waiters = loadWaiters
        loadWaiters = []
        waiters.forEach { $0.resume() }
    }
}
