import MoviesDomainInterface
import Observation
import SwiftUI

/// Owns navigation inside the MovieList feature and builds each screen's interactor and view model.
/// Anything that leaves the feature goes through `MovieListFeatureOutputs`.
@MainActor
@Observable
final class MovieListCoordinator {
    /// Screens reachable inside the feature, pushed onto `path`.
    enum Route: Hashable {
        case detail(Movie.ID)
    }

    /// The feature's navigation stack, bound to `NavigationStack(path:)` in `MovieListView`.
    var path: [Route] = [] {
        didSet { evictDetailViewModels() }
    }

    @ObservationIgnored let viewModel: MovieListViewModel
    @ObservationIgnored private let service: MoviesService
    @ObservationIgnored private let outputs: MovieListFeatureOutputs
    /// One view model per detail on the stack, so re-rendering doesn't refetch; dropped once popped.
    @ObservationIgnored private var detailViewModels: [Movie.ID: MovieDetailViewModel] = [:]

    init(service: MoviesService, outputs: MovieListFeatureOutputs) {
        self.viewModel = MovieListViewModel(interactor: MovieListInteractor(service: service))
        self.service = service
        self.outputs = outputs
    }

    func showDetail(of id: Movie.ID) {
        path.append(.detail(id))
    }

    /// The screen for each route.
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case let .detail(id):
            MovieDetailView(viewModel: detailViewModel(for: id))
        }
    }

    /// Cached only while the detail is on the stack, so a screen re-rendered mid-pop can't re-add an entry.
    func detailViewModel(for id: Movie.ID) -> MovieDetailViewModel {
        if let existing = detailViewModels[id] { return existing }
        let made = MovieDetailViewModel(movieID: id, interactor: MovieDetailInteractor(service: service))
        if path.contains(.detail(id)) {
            detailViewModels[id] = made
        }
        return made
    }

    private func evictDetailViewModels() {
        let onStack = Set(path.map { route in
            switch route {
            case let .detail(id): id
            }
        })
        detailViewModels = detailViewModels.filter { onStack.contains($0.key) }
    }
}
