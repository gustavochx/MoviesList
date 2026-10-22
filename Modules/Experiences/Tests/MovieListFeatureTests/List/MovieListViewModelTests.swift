import Foundation
@testable import MovieListFeature
import MoviesDomainInterface
import Testing

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct MovieListViewModelTests {
    private typealias Call = MovieListInteractorSpyingStub.Call
    private let interactor = MovieListInteractorSpyingStub()

    private func page(_ ids: [Int], page: Int = 1, of totalPages: Int = 1) -> MoviesPage {
        .fixture(movies: ids.map { .fixture(id: $0) }, page: page, totalPages: totalPages)
    }

    private func rows(_ ids: [Int]) -> [MovieRowModel] {
        ids.map { MovieRowModel(movie: .fixture(id: $0)) }
    }

    // MARK: - Loading

    @Test func startsLoading() {
        let sut = MovieListViewModel(interactor: interactor)

        #expect(sut.state == .loading)
    }

    @Test func loadShowsPopularMovies() async {
        interactor.respond(with: .success(page([1, 2], of: 3)))
        let sut = MovieListViewModel(interactor: interactor)

        await sut.load()

        #expect(sut.state == .loaded(rows([1, 2])))
        #expect(sut.canLoadMore)
    }

    @Test func loadTwiceDoesNotRefetch() async {
        interactor.respond(with: .success(page([1])))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()

        await sut.load()

        #expect(interactor.calls == [Call(query: "", page: 1)])
    }

    @Test func noPopularMoviesIsEmpty() async {
        let sut = MovieListViewModel(interactor: interactor)

        await sut.load()

        #expect(sut.state == .empty(.noPopularMovies))
    }

    @Test func loadAfterACancelledLoadStillLoads() async throws {
        interactor.respond(with: .success(page([1])))
        interactor.hold(query: "")
        let sut = MovieListViewModel(interactor: interactor)
        let cancelled = Task { await sut.load() }
        await interactor.waitUntilHeld()
        cancelled.cancel()
        interactor.release()
        await cancelled.value
        interactor.hold(query: nil)

        await sut.load()

        #expect(sut.state == .loaded(rows([1])))
    }

    @Test func loadAndAnInitialEmptySearchFetchOnce() async {
        interactor.respond(with: .success(page([1])))
        interactor.hold(query: "")
        let sut = MovieListViewModel(interactor: interactor)
        let load = Task { await sut.load() }
        await interactor.waitUntilHeld()

        let search = Task { await sut.search("") }
        await Task.yield()
        interactor.release()
        await load.value
        await search.value

        #expect(interactor.calls == [Call(query: "", page: 1)])
        #expect(sut.state == .loaded(rows([1])))
    }

    @Test func loadDuringACancelledLoadStillLoads() async {
        interactor.respond(with: .success(page([1])))
        interactor.hold(query: "")
        let sut = MovieListViewModel(interactor: interactor)
        let cancelled = Task { await sut.load() }
        await interactor.waitUntilHeld()
        cancelled.cancel()

        let next = Task { await sut.load() }
        await Task.yield()
        interactor.hold(query: nil)
        interactor.release()
        await cancelled.value
        await next.value

        #expect(sut.state == .loaded(rows([1])))
        #expect(interactor.calls.count == 2)
    }

    // MARK: - Search

    @Test func searchShowsResults() async {
        interactor.respond(to: "dune", with: .success(page([9])))
        let sut = MovieListViewModel(interactor: interactor)

        await sut.search("dune")

        #expect(sut.state == .loaded(rows([9])))
    }

    @Test func clearingSearchReturnsToPopular() async {
        interactor.respond(with: .success(page([1])))
        interactor.respond(to: "dune", with: .success(page([9])))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.search("dune")

        await sut.search("")

        #expect(sut.state == .loaded(rows([1])))
        #expect(sut.query.isEmpty)
    }

    @Test func searchWithoutResultsIsEmptyForThatQuery() async {
        let sut = MovieListViewModel(interactor: interactor)

        await sut.search("  zzzz ")

        #expect(sut.state == .empty(.noResults(query: "zzzz")))
    }

    @Test func sameSearchTextDoesNotRefetch() async {
        let sut = MovieListViewModel(interactor: interactor)
        await sut.search("dune")

        await sut.search("dune ")

        #expect(interactor.calls == [Call(query: "dune", page: 1)])
    }

    @Test func repeatingACancelledSearchLoadsIt() async throws {
        interactor.respond(to: "dune", with: .success(page([9])))
        interactor.hold(query: "dune")
        let sut = MovieListViewModel(interactor: interactor)
        let cancelled = Task { await sut.search("dune") }
        await interactor.waitUntilHeld()
        cancelled.cancel()
        interactor.release()
        await cancelled.value
        try #require(sut.state == .loading)
        interactor.hold(query: nil)

        await sut.search("dune ")

        #expect(sut.state == .loaded(rows([9])))
    }

    @Test func repeatingASearchWhileItsCancelledRequestIsInFlightLoadsIt() async {
        interactor.respond(to: "dune", with: .success(page([9])))
        interactor.hold(query: "dune")
        let sut = MovieListViewModel(interactor: interactor)
        let cancelled = Task { await sut.search("dune") }
        await interactor.waitUntilHeld()
        cancelled.cancel()

        let repeated = Task { await sut.search("dune") }
        await Task.yield()
        interactor.hold(query: nil)
        interactor.release()
        await cancelled.value
        await repeated.value

        #expect(sut.state == .loaded(rows([9])))
    }

    @Test func staleResponsesAreIgnored() async {
        interactor.respond(to: "slow", with: .success(page([1])))
        interactor.respond(to: "fast", with: .success(page([2])))
        interactor.hold(query: "slow")
        let sut = MovieListViewModel(interactor: interactor)
        let slow = Task { await sut.search("slow") }
        await interactor.waitUntilHeld()

        await sut.search("fast")
        interactor.release()
        await slow.value

        #expect(sut.state == .loaded(rows([2])))
        #expect(sut.query == "fast")
    }

    // MARK: - Errors

    @Test(arguments: [
        (MoviesError.offline as any Error, LoadFailure.offline),
        (MoviesError.unauthorized, .missingAPIKey),
        (MoviesError.unavailable, .generic),
        (URLError(.badServerResponse), .generic)
    ])
    func errorsAreMapped(error: any Error, expected: LoadFailure) async {
        interactor.respond(with: .failure(error))
        let sut = MovieListViewModel(interactor: interactor)

        await sut.load()

        #expect(sut.state == .failed(expected))
    }

    @Test func cancellationIsNotShownAsAnError() async {
        interactor.respond(with: .failure(CancellationError()))
        let sut = MovieListViewModel(interactor: interactor)

        await sut.load()

        #expect(sut.state == .loading)
    }

    @Test func retryAfterFailureLoads() async {
        interactor.respond(with: .failure(MoviesError.offline))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()
        interactor.respond(with: .success(page([1])))

        await sut.retry()

        #expect(sut.state == .loaded(rows([1])))
    }

    // MARK: - Pagination

    @Test func loadMoreIgnoresRowsBeforeTheLast() async {
        interactor.respond(with: .success(page([1, 2], page: 1, of: 2)))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()

        await sut.loadMoreIfNeeded(after: MovieRowModel(movie: .fixture(id: 1)))

        #expect(interactor.calls == [Call(query: "", page: 1)])
    }

    @Test func loadMoreAppendsTheNextPage() async {
        interactor.respond(with: .success(page([1, 2], page: 1, of: 2)))
        interactor.respond(page: 2, with: .success(page([2, 3], page: 2, of: 2)))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()

        await sut.loadMoreIfNeeded(after: MovieRowModel(movie: .fixture(id: 2)))

        #expect(sut.state == .loaded(rows([1, 2, 3])))
        #expect(!sut.canLoadMore)
    }

    @Test func loadMoreStopsOnTheLastPage() async {
        interactor.respond(with: .success(page([1])))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()

        await sut.loadMore()

        #expect(interactor.calls == [Call(query: "", page: 1)])
    }

    @Test func loadMoreFailureKeepsTheRows() async {
        interactor.respond(with: .success(page([1], page: 1, of: 2)))
        interactor.respond(page: 2, with: .failure(MoviesError.offline))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()

        await sut.loadMore()

        #expect(sut.state == .loaded(rows([1])))
        #expect(sut.loadMoreFailed)
        #expect(!sut.isLoadingMore)
    }

    @Test func retryAfterLoadMoreFailureAppends() async {
        interactor.respond(with: .success(page([1], page: 1, of: 2)))
        interactor.respond(page: 2, with: .failure(MoviesError.offline))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()
        await sut.loadMore()
        interactor.respond(page: 2, with: .success(page([2], page: 2, of: 2)))

        await sut.loadMore()

        #expect(sut.state == .loaded(rows([1, 2])))
        #expect(!sut.loadMoreFailed)
    }

    // MARK: - Refresh

    @Test func refreshKeepsRowsWhileLoading() async throws {
        interactor.respond(with: .success(page([1])))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()
        interactor.respond(with: .success(page([2])))
        interactor.hold(query: "")

        let refresh = Task { await sut.refresh() }
        await interactor.waitUntilHeld()
        try #require(sut.state == .loaded(rows([1])))
        interactor.release()
        await refresh.value

        #expect(sut.state == .loaded(rows([2])))
    }

    @Test func loadMoreDuringRefreshIsIgnored() async {
        interactor.respond(with: .success(page([1], page: 1, of: 2)))
        interactor.respond(page: 2, with: .success(page([2], page: 2, of: 2)))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()
        interactor.respond(with: .success(page([5], page: 1, of: 2)))
        interactor.hold(query: "")
        let refresh = Task { await sut.refresh() }
        await interactor.waitUntilHeld()

        await sut.loadMore()
        interactor.release()
        await refresh.value

        #expect(interactor.calls == [Call(query: "", page: 1), Call(query: "", page: 1)])
        #expect(sut.state == .loaded(rows([5])))
    }

    @Test func failedRefreshShowsTheError() async {
        interactor.respond(with: .success(page([1])))
        let sut = MovieListViewModel(interactor: interactor)
        await sut.load()
        interactor.respond(with: .failure(MoviesError.offline))

        await sut.refresh()

        #expect(sut.state == .failed(.offline))
    }
}
