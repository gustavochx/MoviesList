import Testing
import MoviesDomainInterface
@testable import MoviesDomain

@Suite struct LiveMoviesServiceTests {
    private let repository = MovieRepositorySpyingStub()

    @Test(arguments: ["", "   ", "\n"])
    func blankQueryReturnsPopular(query: String) async throws {
        let sut = LiveMoviesService(repository: repository)

        _ = try await sut.search(query, page: 2)

        #expect(repository.calls == [.popular(page: 2)])
    }

    @Test func queryIsTrimmed() async throws {
        let sut = LiveMoviesService(repository: repository)

        _ = try await sut.search("  dune ", page: 1)

        #expect(repository.calls == [.search(query: "dune", page: 1)])
    }

    @Test func untitledMoviesAreDropped() async throws {
        repository.popularResultToBeReturned = .success(.fixture(
            movies: [.fixture(id: 1), .fixture(id: 2, title: " ")],
            totalPages: 5
        ))
        let sut = LiveMoviesService(repository: repository)

        let page = try await sut.popular(page: 1)

        #expect(page.movies.map(\.id) == [1])
        #expect(page.totalPages == 5)
    }

    @Test func errorsPassThrough() async {
        repository.popularResultToBeReturned = .failure(MoviesError.offline)
        let sut = LiveMoviesService(repository: repository)

        await #expect(throws: MoviesError.offline) { try await sut.popular(page: 1) }
    }
}
