//
//  AppCoordinator.swift
//  MoviesList
//

import MovieListFeature
import Foundation
import Observation
import SwiftUI
import MoviesDomain
import MoviesDomainInterface

/// Composes the app from its features and owns every navigation that crosses a feature boundary.
/// Each feature keeps its own internal flow in its own coordinator and leaves only through its outputs.
/// This is also the composition root: the only place that picks concrete implementations.
@MainActor
@Observable
final class AppCoordinator {
    @ObservationIgnored private let movies: MoviesService

    @ObservationIgnored private lazy var movieListFeature = MovieListFeatureEntry(
        dependencies: MovieListFeatureDependencies(movies: movies),
        outputs: MovieListFeatureOutputs()
    )

    init() {
        movies = LiveMoviesService(repository: InMemoryMovieRepository())
    }

    func makeRootView() -> some View {
        movieListFeature.makeRootView()
    }
}

/// Keeps Movie values in memory until a data module exists.
private actor InMemoryMovieRepository: MovieRepository {
    private var items: [Movie] = []

    func all() async throws -> [Movie] {
        items
    }

    func save(_ item: Movie) async throws {
        items.append(item)
    }
}
