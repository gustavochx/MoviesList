import MoviesDomainInterface
import Foundation
import Observation

@MainActor
@Observable
final class MovieListViewModel {
    enum State: Equatable {
        case loading
        case loaded([MovieRowModel])
        case empty(EmptyReason)
        case failed(LoadFailure)
    }

    enum EmptyReason: Equatable {
        case noPopularMovies
        case noResults(query: String)
    }


    private(set) var state: State = .loading
    /// The search text the current results belong to; empty means popular movies.
    private(set) var query = ""
    private(set) var canLoadMore = false
    private(set) var isLoadingMore = false
    private(set) var loadMoreFailed = false

    @ObservationIgnored private let interactor: MovieListInteracting
    @ObservationIgnored private var page = 0
    /// Bumped on every new query so responses for an older one are dropped.
    @ObservationIgnored private var generation = 0
    /// True while a first-page request is in flight; cleared when it ends, even by cancellation.
    @ObservationIgnored private var isReloading = false
    /// Callers waiting for the first-page request in flight to end before deciding whether to load.
    @ObservationIgnored private var reloadWaiters: [CheckedContinuation<Void, Never>] = []

    init(interactor: MovieListInteracting) {
        self.interactor = interactor
    }

    /// First load. Does nothing once results are on screen. While a first-page request is in flight
    /// it waits for it, and loads only if that request ended without a result (it was cancelled).
    func load() async {
        await waitForReload()
        guard page == 0 || state == .loading, !Task.isCancelled else { return }
        await reload(showingLoading: true)
    }

    func search(_ text: String) async {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == query {
            // Same text: let its request in flight finish, then load only if it was cancelled
            // and the spinner is still up.
            await waitForReload()
            guard state == .loading, !Task.isCancelled else { return }
        }
        query = text
        await reload(showingLoading: true)
    }

    func retry() async {
        await reload(showingLoading: true)
    }

    /// Pull to refresh: keeps the current rows on screen until the new ones arrive;
    /// a failed refresh shows the full-screen error like any other load.
    func refresh() async {
        await reload(showingLoading: false)
    }

    /// Loads the next page when `row` is the last one shown.
    func loadMoreIfNeeded(after row: MovieRowModel) async {
        guard case let .loaded(rows) = state, row.id == rows.last?.id else { return }
        await loadMore()
    }

    func loadMore() async {
        // During a refresh the rows on screen are about to be replaced, so don't extend them.
        guard case let .loaded(rows) = state, canLoadMore, !isLoadingMore, !isReloading else { return }
        let current = generation
        isLoadingMore = true
        loadMoreFailed = false
        defer { if current == generation { isLoadingMore = false } }
        do {
            let next = try await interactor.movies(matching: query, page: page + 1)
            guard current == generation else { return }
            let known = Set(rows.map(\.id))
            state = .loaded(rows + next.movies.filter { !known.contains($0.id) }.map { MovieRowModel(movie: $0) })
            page = next.page
            canLoadMore = next.hasMore
        } catch {
            guard current == generation, !isCancellation(error) else { return }
            loadMoreFailed = true
        }
    }

    private func reload(showingLoading: Bool) async {
        generation += 1
        let current = generation
        isReloading = true
        defer {
            if current == generation {
                isReloading = false
                resumeReloadWaiters()
            }
        }
        if showingLoading { state = .loading }
        isLoadingMore = false
        loadMoreFailed = false
        do {
            let first = try await interactor.movies(matching: query, page: 1)
            guard current == generation else { return }
            page = first.page
            canLoadMore = first.hasMore
            if first.movies.isEmpty {
                state = .empty(query.isEmpty ? .noPopularMovies : .noResults(query: query))
            } else {
                state = .loaded(first.movies.map { MovieRowModel(movie: $0) })
            }
        } catch {
            guard current == generation, !isCancellation(error) else { return }
            page = 0
            canLoadMore = false
            state = .failed(LoadFailure(error))
        }
    }

    private func waitForReload() async {
        while isReloading {
            await withCheckedContinuation { reloadWaiters.append($0) }
        }
    }

    private func resumeReloadWaiters() {
        let waiters = reloadWaiters
        reloadWaiters = []
        waiters.forEach { $0.resume() }
    }

    /// A cancelled task (the user typed again, or the screen went away) is not a failure to show.
    private func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || Task.isCancelled
    }
}
