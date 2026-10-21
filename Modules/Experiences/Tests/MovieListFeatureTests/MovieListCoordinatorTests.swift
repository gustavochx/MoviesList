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

    @Test func detailViewModelIsReusedWhileOnTheStack() {
        let sut = MovieListCoordinator(service: MoviesServiceSpyingStub(), outputs: MovieListFeatureOutputs())
        sut.showDetail(of: 42)

        let first = sut.detailViewModel(for: 42)
        let second = sut.detailViewModel(for: 42)

        #expect(first === second)
        #expect(first.movieID == 42)
    }

    @Test func detailViewModelIsDroppedAfterPop() {
        let sut = MovieListCoordinator(service: MoviesServiceSpyingStub(), outputs: MovieListFeatureOutputs())
        sut.showDetail(of: 42)
        let pushed = sut.detailViewModel(for: 42)

        sut.path.removeLast()
        sut.showDetail(of: 42)

        #expect(sut.detailViewModel(for: 42) !== pushed)
    }

    @Test func popKeepsDetailsStillOnTheStack() {
        let sut = MovieListCoordinator(service: MoviesServiceSpyingStub(), outputs: MovieListFeatureOutputs())
        sut.showDetail(of: 1)
        let first = sut.detailViewModel(for: 1)
        sut.showDetail(of: 2)
        _ = sut.detailViewModel(for: 2)

        sut.path.removeLast()

        #expect(sut.detailViewModel(for: 1) === first)
    }

    @Test func detailViewModelForAnIDOffTheStackIsNotCached() {
        let sut = MovieListCoordinator(service: MoviesServiceSpyingStub(), outputs: MovieListFeatureOutputs())

        let first = sut.detailViewModel(for: 9)
        let second = sut.detailViewModel(for: 9)

        #expect(first !== second)
    }

    @Test func entryBuildsOneCoordinatorAndKeepsIt() {
        let sut = MovieListFeatureEntry(dependencies: MovieListFeatureDependencies(movies: MoviesServiceSpyingStub()))

        let first = sut.coordinator()
        let second = sut.coordinator()

        #expect(first === second)
    }
}
