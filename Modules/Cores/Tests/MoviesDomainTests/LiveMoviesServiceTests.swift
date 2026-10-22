@testable import MoviesDomain
import MoviesDomainInterface
import Testing

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

    @Test func detailsKeepsTheTopBilledNamedCast() async throws {
        let cast = (1...20).map { CastMember.fixture(id: $0, name: $0 == 2 ? " " : "Actor \($0)") }
        repository.detailsResultToBeReturned = .success(.fixture(id: 7, cast: cast))
        let sut = LiveMoviesService(repository: repository)

        let details = try await sut.details(id: 7)

        #expect(details.cast.count == LiveMoviesService.castLimit)
        #expect(details.cast.first?.id == 1)
        #expect(!details.cast.contains { $0.id == 2 })
        #expect(repository.calls == [.details(id: 7)])
    }

    @Test func detailsMergesAPersonBilledForSeveralRoles() async throws {
        let cast: [CastMember] = [
            .fixture(id: 1, name: "Actor One", character: "Hero"),
            .fixture(id: 2, name: "Actor Two", character: "Sidekick"),
            .fixture(id: 1, name: "Actor One", character: "Villain")
        ]
        repository.detailsResultToBeReturned = .success(.fixture(cast: cast))
        let sut = LiveMoviesService(repository: repository)

        let details = try await sut.details(id: 1)

        #expect(details.cast.map(\.id) == [1, 2])
        #expect(details.cast.first?.character == "Hero / Villain")
    }

    @Test func detailsErrorsPassThrough() async {
        repository.detailsResultToBeReturned = .failure(MoviesError.notFound)
        let sut = LiveMoviesService(repository: repository)

        await #expect(throws: MoviesError.notFound) { try await sut.details(id: 7) }
    }

    @Test func errorsPassThrough() async {
        repository.popularResultToBeReturned = .failure(MoviesError.offline)
        let sut = LiveMoviesService(repository: repository)

        await #expect(throws: MoviesError.offline) { try await sut.popular(page: 1) }
    }
}
