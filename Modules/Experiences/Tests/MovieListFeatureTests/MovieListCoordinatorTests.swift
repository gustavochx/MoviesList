import MoviesDomainInterface
import Testing
@testable import MovieListFeature

@MainActor
@Suite struct MovieListCoordinatorTests {
    @Test func showDetailPushesTheDetailRoute() {
        let sut = MovieListCoordinator(service: MoviesServiceSpyingStub(), outputs: MovieListFeatureOutputs())

        sut.showDetail(of: 42)

        #expect(sut.path == [.detail(42)])
    }

    @Test func entryBuildsOneCoordinatorAndKeepsIt() {
        let sut = MovieListFeatureEntry(dependencies: MovieListFeatureDependencies(movies: MoviesServiceSpyingStub()))

        let first = sut.coordinator()
        let second = sut.coordinator()

        #expect(first === second)
    }
}
