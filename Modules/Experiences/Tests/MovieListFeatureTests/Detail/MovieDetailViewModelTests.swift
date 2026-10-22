import Foundation
@testable import MovieListFeature
import MoviesDomainInterface
import Testing

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct MovieDetailViewModelTests {
    private let interactor = MovieDetailInteractorSpyingStub()

    private func makeSUT(id: Movie.ID = 7) -> MovieDetailViewModel {
        MovieDetailViewModel(movieID: id, interactor: interactor)
    }

    @Test func startsLoadingWithoutATitle() {
        let sut = makeSUT()

        #expect(sut.state == .loading)
        #expect(sut.title.isEmpty)
    }

    @Test func loadShowsTheDetails() async {
        let details = MovieDetails.fixture(id: 7, title: "Dune: Part Two")
        interactor.detailsResultToBeReturned = .success(details)
        let sut = makeSUT()

        await sut.load()

        #expect(sut.state == .loaded(MovieDetailModel(details: details)))
        #expect(sut.title == "Dune: Part Two")
        #expect(interactor.requestedIDs == [7])
    }

    @Test func loadTwiceFetchesOnce() async {
        let sut = makeSUT()
        await sut.load()

        await sut.load()

        #expect(interactor.requestedIDs == [7])
    }

    @Test func loadWhileALoadIsInFlightFetchesOnce() async {
        interactor.holdsCalls = true
        let sut = makeSUT()
        let first = Task { await sut.load() }
        await interactor.waitUntilHeld()

        let second = Task { await sut.load() }
        await Task.yield()
        interactor.release()
        await first.value
        await second.value

        #expect(interactor.requestedIDs == [7])
        #expect(sut.state == .loaded(MovieDetailModel(details: .fixture())))
    }

    @Test func missingMovieShowsNotFound() async {
        interactor.detailsResultToBeReturned = .failure(MoviesError.notFound)
        let sut = makeSUT()

        await sut.load()

        #expect(sut.state == .notFound)
    }

    @Test(arguments: [
        (MoviesError.offline as any Error, LoadFailure.offline),
        (MoviesError.unauthorized, .missingAPIKey),
        (MoviesError.unavailable, .generic),
        (URLError(.badServerResponse), .generic)
    ])
    func errorsAreMapped(error: any Error, expected: LoadFailure) async {
        interactor.detailsResultToBeReturned = .failure(error)
        let sut = makeSUT()

        await sut.load()

        #expect(sut.state == .failed(expected))
    }

    @Test func retryAfterFailureLoads() async {
        interactor.detailsResultToBeReturned = .failure(MoviesError.offline)
        let sut = makeSUT()
        await sut.load()
        interactor.detailsResultToBeReturned = .success(.fixture(id: 7))

        await sut.retry()

        #expect(sut.state == .loaded(MovieDetailModel(details: .fixture(id: 7))))
    }

    @Test func anOlderResponseAfterRetryIsIgnored() async {
        // Given: a first load still waiting, and a retry that already succeeded
        interactor.holdsCalls = true
        let sut = makeSUT()
        let staleLoad = Task { await sut.load() }
        await interactor.waitUntilHeld()
        interactor.holdsCalls = false
        interactor.detailsResultToBeReturned = .success(.fixture(id: 7, title: "Fresh"))
        await sut.retry()

        // When: the first load finally answers, with a failure
        interactor.detailsResultToBeReturned = .failure(MoviesError.offline)
        interactor.release()
        await staleLoad.value

        // Then: the retry's result stays on screen
        #expect(sut.title == "Fresh")
    }

    @Test func loadDuringACancelledLoadStillLoads() async {
        interactor.holdsCalls = true
        let sut = makeSUT()
        let cancelled = Task { await sut.load() }
        await interactor.waitUntilHeld()
        cancelled.cancel()

        let next = Task { await sut.load() }
        await Task.yield()
        interactor.holdsCalls = false
        interactor.release()
        await cancelled.value
        await next.value

        #expect(sut.state == .loaded(MovieDetailModel(details: .fixture())))
        #expect(interactor.requestedIDs == [7, 7])
    }

    @Test func loadAfterACancelledLoadStillLoads() async throws {
        interactor.holdsCalls = true
        let sut = makeSUT()
        let cancelled = Task { await sut.load() }
        await interactor.waitUntilHeld()
        cancelled.cancel()
        interactor.release()
        await cancelled.value
        try #require(sut.state == .loading)
        interactor.holdsCalls = false

        await sut.load()

        #expect(sut.state == .loaded(MovieDetailModel(details: .fixture())))
    }
}
