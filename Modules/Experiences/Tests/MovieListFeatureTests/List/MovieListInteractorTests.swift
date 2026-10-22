@testable import MovieListFeature
import MoviesDomainInterface
import Testing

@Suite struct MovieListInteractorTests {
    private let service = MoviesServiceSpyingStub()

    @Test func blankQueryIsLeftToTheDomain() async throws {
        let sut = MovieListInteractor(service: service)

        _ = try await sut.movies(matching: "", page: 2)

        #expect(service.calls == [.search(query: "", page: 2)])
    }

    @Test func queryRunsASearch() async throws {
        service.searchResultToBeReturned = .success(.fixture(movies: [.fixture(id: 2)]))
        let sut = MovieListInteractor(service: service)

        let page = try await sut.movies(matching: "dune", page: 1)

        #expect(page.movies.map(\.id) == [2])
        #expect(service.calls == [.search(query: "dune", page: 1)])
    }

    @Test func rethrowsServiceErrors() async {
        service.searchResultToBeReturned = .failure(MoviesError.offline)
        let sut = MovieListInteractor(service: service)

        await #expect(throws: MoviesError.offline) { try await sut.movies(matching: "dune", page: 1) }
    }
}
