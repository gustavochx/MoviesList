import Foundation
import Testing
import MoviesDomainInterface
@testable import MoviesDomain

@Suite struct LiveMoviesServiceTests {
    private struct FakeRepository: MovieRepository {
        var items: [Movie]
        func all() async throws -> [Movie] { items }
        func save(_ item: Movie) async throws {}
    }

    @Test func returnsItemsNewestFirst() async throws {
        let old = Movie(createdAt: Date(timeIntervalSince1970: 100))
        let new = Movie(createdAt: Date(timeIntervalSince1970: 200))
        let sut = LiveMoviesService(repository: FakeRepository(items: [old, new]))

        let result = try await sut.all()

        #expect(result == [new, old])
    }

    @Test func returnsNothingWhenRepositoryIsEmpty() async throws {
        let sut = LiveMoviesService(repository: FakeRepository(items: []))

        #expect(try await sut.all().isEmpty)
    }
}
