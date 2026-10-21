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
        case failed(MovieListError)
    }

    enum EmptyReason: Equatable {
        case noPopularMovies
        case noResults(query: String)
    }

    enum MovieListError: Equatable {
        case offline
        case missingAPIKey
        case generic

        init(_ error: Error) {
            switch error as? MoviesError {
            case .offline: self = .offline
            case .unauthorized: self = .missingAPIKey
            case .unavailable, nil: self = .generic
            }
        }
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

    init(interactor: MovieListInteracting) {
        self.interactor = interactor
    }

    /// First load. Does nothing once results are on screen, so re-appearing doesn't refetch.
    /// Still loads when a previous request was cancelled before anything was shown.
    func load() async {
        guard page == 0 || state == .loading else { return }
        await reload(showingLoading: true)
    }

    func search(_ text: String) async {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Same text: nothing to do, unless its request was cancelled and the spinner is still up.
        guard text != query || state == .loading else { return }
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
        guard case let .loaded(rows) = state, canLoadMore, !isLoadingMore else { return }
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
            state = .failed(MovieListError(error))
        }
    }

    /// A cancelled task (the user typed again, or the screen went away) is not a failure to show.
    private func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || Task.isCancelled
    }
}
