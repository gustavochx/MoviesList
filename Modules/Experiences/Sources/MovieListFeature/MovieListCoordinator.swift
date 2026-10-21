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
    var path: [Route] = []

    @ObservationIgnored let viewModel: MovieListViewModel
    @ObservationIgnored private let outputs: MovieListFeatureOutputs

    init(service: MoviesService, outputs: MovieListFeatureOutputs) {
        self.viewModel = MovieListViewModel(interactor: MovieListInteractor(service: service))
        self.outputs = outputs
    }

    func showDetail(of id: Movie.ID) {
        path.append(.detail(id))
    }

    /// The screen for each route. Placeholder until the detail screen exists.
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .detail:
            ContentUnavailableView("Details coming soon", systemImage: "film")
        }
    }
}
