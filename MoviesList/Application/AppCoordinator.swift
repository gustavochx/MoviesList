//
//  AppCoordinator.swift
//  MoviesList
//

import Foundation
import MovieListFeature
import MoviesData
import MoviesDomain
import MoviesDomainInterface
import Observation
import SwiftUI

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

    init(bundle: Bundle = .main) {
        let configuration = TMDBConfiguration(apiKey: Self.apiKey(in: bundle))
        movies = LiveMoviesService(repository: TMDBMovieRepository(configuration: configuration))
    }

    func makeRootView() -> some View {
        movieListFeature.makeRootView()
    }

    /// The TMDB key injected at build time from Config/Secrets.xcconfig (gitignored) through Config/Info.plist.
    /// Empty when the secrets file is missing; the feature then shows its "API key missing" state.
    private static func apiKey(in bundle: Bundle) -> String {
        let value = bundle.object(forInfoDictionaryKey: "TMDBAPIKey") as? String ?? ""
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
