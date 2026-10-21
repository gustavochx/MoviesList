import MoviesDomainInterface
import Foundation
import Testing
@testable import MovieListFeature

@MainActor
@Suite struct MovieListFeatureTests {
    private struct FakeService: MoviesService {
        var result: Result<[Movie], Error>
        func all() async throws -> [Movie] { try result.get() }
    }

    private struct FakeInteractor: MovieListInteracting {
        var result: Result<[Movie], Error>
        func loadMovies() async throws -> [Movie] { try result.get() }
    }

    private struct Failure: Error {}

    @Test func loadsItemsFromTheInteractor() async {
        let item = Movie(createdAt: Date(timeIntervalSince1970: 100))
        let sut = MovieListViewModel(interactor: FakeInteractor(result: .success([item])))

        await sut.load()

        #expect(sut.state == .loaded([item]))
    }

    @Test func showsEmptyWhenThereAreNoItems() async {
        let sut = MovieListViewModel(interactor: FakeInteractor(result: .success([])))

        await sut.load()

        #expect(sut.state == .empty)
    }

    @Test func showsFailureWhenTheInteractorThrows() async {
        let sut = MovieListViewModel(interactor: FakeInteractor(result: .failure(Failure())))

        await sut.load()

        #expect(sut.state == .failed(message: "Couldn't load. Try again."))
    }

    @Test func showDetailPushesTheDetailRoute() {
        let movie = Movie(createdAt: Date(timeIntervalSince1970: 100))
        let sut = MovieListCoordinator(service: FakeService(result: .success([])), outputs: MovieListFeatureOutputs())

        sut.showDetail(of: movie.id)

        #expect(sut.path == [.detail(movie.id)])
    }

    @Test func entryBuildsOneCoordinatorAndKeepsIt() {
        let entry = MovieListFeatureEntry(dependencies: MovieListFeatureDependencies(movies: FakeService(result: .success([]))))

        #expect(entry.coordinator() === entry.coordinator())
    }
}
