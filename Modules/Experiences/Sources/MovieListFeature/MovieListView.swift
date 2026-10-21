import MoviesDomainInterface
import SwiftUI

struct MovieListView: View {
    @Bindable var coordinator: MovieListCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MovieListContent(viewModel: coordinator.viewModel)
                .navigationTitle("MovieList")
                .navigationDestination(for: MovieListCoordinator.Route.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}

/// The list screen itself. Kept separate so changes to the navigation path don't re-evaluate it.
private struct MovieListContent: View {
    let viewModel: MovieListViewModel

    var body: some View {
        content
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView("Nothing here yet", systemImage: "tray")
        case let .loaded(items):
            List(items) { item in
                Text(item.createdAt, style: .date)
            }
        case let .failed(message):
            ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
        }
    }
}
