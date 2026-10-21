import Foundation
import MoviesDomainInterface
import Testing
@testable import MovieListFeature

@Suite struct MovieListInteractorTests {
    private struct FakeService: MoviesService {
        var result: Result<[Movie], Error>
        func all() async throws -> [Movie] { try result.get() }
    }

    private struct Failure: Error {}

    @Test func returnsMoviesFromTheService() async throws {
        let movie = Movie(createdAt: Date(timeIntervalSince1970: 100))
        let sut = MovieListInteractor(service: FakeService(result: .success([movie])))

        #expect(try await sut.loadMovies() == [movie])
    }

    @Test func rethrowsServiceErrors() async {
        let sut = MovieListInteractor(service: FakeService(result: .failure(Failure())))

        await #expect(throws: Failure.self) { try await sut.loadMovies() }
    }
}
