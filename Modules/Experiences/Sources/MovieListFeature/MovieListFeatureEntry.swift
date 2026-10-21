import MoviesDomainInterface
import Observation
import SwiftUI

/// Inputs: everything MovieList needs from the outside world, as protocols.
/// The app's coordinator provides the concrete implementations.
public struct MovieListFeatureDependencies {
    public var movies: MoviesService

    public init(movies: MoviesService) {
        self.movies = movies
    }
}

/// Outputs: the ways MovieList can leave itself. The app's coordinator decides what each one does.
/// Add closures here (e.g. `public var openSettings: () -> Void`), each defaulting to a no-op.
public struct MovieListFeatureOutputs {
    public init() {}
}

/// Input channel: lets the app send commands into a running MovieList, e.g. after data changes elsewhere.
/// It also owns MovieList's coordinator, so the same instance survives every re-render of the app.
@MainActor
@Observable
public final class MovieListFeatureController {
    @ObservationIgnored private var coordinator: MovieListCoordinator?

    public init() {}

    func coordinator(orMake make: () -> MovieListCoordinator) -> MovieListCoordinator {
        if let coordinator { return coordinator }
        let made = make()
        coordinator = made
        return made
    }

    /// Reloads what MovieList shows.
    public func reload() async {
        await coordinator?.viewModel.retry()
    }
}

/// Entry point for the MovieList feature. Navigation between its own screens belongs to
/// `MovieListCoordinator`; everything else in this module stays `internal`.
public struct MovieListFeatureEntry {
    public let controller: MovieListFeatureController
    private let dependencies: MovieListFeatureDependencies
    private let outputs: MovieListFeatureOutputs

    @MainActor
    public init(dependencies: MovieListFeatureDependencies, outputs: MovieListFeatureOutputs = MovieListFeatureOutputs()) {
        self.dependencies = dependencies
        self.outputs = outputs
        self.controller = MovieListFeatureController()
    }

    @MainActor
    public func makeRootView() -> some View {
        MovieListView(coordinator: coordinator())
    }

    /// The feature's single coordinator, created on first use and kept by `controller`.
    @MainActor
    func coordinator() -> MovieListCoordinator {
        controller.coordinator {
            MovieListCoordinator(service: dependencies.movies, outputs: outputs)
        }
    }
}
