import MoviesDomainInterface
import SwiftUI

/// The list screen itself. Kept separate from `MovieListView` so changes to the navigation path don't re-evaluate it.
/// It has no `.task { load() }` on purpose: the first load comes from the parent's `.task(id: searchText)`,
/// which runs on appear with an empty query.
struct MovieListContent: View {
    let viewModel: MovieListViewModel
    let onSelect: (Movie.ID) -> Void

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension MovieListContent {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .loading:
            loading
        case let .loaded(rows):
            MovieRowsList(viewModel: viewModel, rows: rows, onSelect: onSelect)
        case .empty(.noPopularMovies):
            noPopularMovies
        case let .empty(.noResults(query)):
            ContentUnavailableView
                .search(text: query)
        case let .failed(failure):
            LoadFailureView(failure: failure, genericTitle: "Couldn't load movies") {
                Task { await viewModel.retry() }
            }
        }
    }

    var loading: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var noPopularMovies: some View {
        ContentUnavailableView {
            Label("No movies right now", systemImage: "film")
        } description: {
            Text("Popular movies will show up here.")
        } actions: {
            Button("Try Again") { Task { await viewModel.retry() } }
        }
    }
}
