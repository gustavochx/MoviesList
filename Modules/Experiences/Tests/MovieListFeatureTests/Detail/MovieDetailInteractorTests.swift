@testable import MovieListFeature
import MoviesDomainInterface
import Testing

@Suite struct MovieDetailInteractorTests {
    private let service = MoviesServiceSpyingStub()

    @Test func forwardsTheIDToTheService() async throws {
        service.detailsResultToBeReturned = .success(.fixture(id: 42))
        let sut = MovieDetailInteractor(service: service)

        let details = try await sut.details(id: 42)

        #expect(details.id == 42)
        #expect(service.calls == [.details(id: 42)])
    }

    @Test func rethrowsServiceErrors() async {
        service.detailsResultToBeReturned = .failure(MoviesError.notFound)
        let sut = MovieDetailInteractor(service: service)

        await #expect(throws: MoviesError.notFound) { try await sut.details(id: 42) }
    }
}
