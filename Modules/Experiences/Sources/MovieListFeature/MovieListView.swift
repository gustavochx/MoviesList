import MoviesDomainInterface
import SwiftUI

struct MovieListView: View {
    @Bindable var coordinator: MovieListCoordinator
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MovieListContent(viewModel: coordinator.viewModel, onSelect: coordinator.showDetail(of:))
                .navigationTitle("Popular Movies")
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search movies"
                )
                .task(id: searchText) {
                    // Debounce typing; clearing the field returns to popular movies right away.
                    if !searchText.isEmpty {
                        do { try await Task.sleep(for: .milliseconds(300)) } catch { return }
                    }
                    await coordinator.viewModel.search(searchText)
                }
                .navigationDestination(for: MovieListCoordinator.Route.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}

/// The list screen itself. Kept separate so changes to the navigation path don't re-evaluate it.
private struct MovieListContent: View {
    let viewModel: MovieListViewModel
    let onSelect: (Movie.ID) -> Void

    // The first load comes from the parent's `.task(id: searchText)`, which runs on appear with an empty query.
    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(rows):
            MovieRowsList(viewModel: viewModel, rows: rows, onSelect: onSelect)
        case .empty(.noPopularMovies):
            ContentUnavailableView {
                Label("No movies right now", systemImage: "film")
            } description: {
                Text("Popular movies will show up here.")
            } actions: {
                Button("Try Again") { Task { await viewModel.retry() } }
            }
        case let .empty(.noResults(query)):
            ContentUnavailableView.search(text: query)
        case let .failed(error):
            ContentUnavailableView {
                Label(error.title, systemImage: error.systemImage)
            } description: {
                Text(error.message)
            } actions: {
                Button("Try Again") { Task { await viewModel.retry() } }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct MovieRowsList: View {
    let viewModel: MovieListViewModel
    let rows: [MovieRowModel]
    let onSelect: (Movie.ID) -> Void

    var body: some View {
        List {
            Section {
                ForEach(rows) { row in
                    Button { onSelect(row.id) } label: {
                        MovieRow(row: row)
                    }
                    .foregroundStyle(.primary)
                    .task { await viewModel.loadMoreIfNeeded(after: row) }
                }
            } footer: {
                VStack(spacing: 12) {
                    if viewModel.isLoadingMore {
                        ProgressView()
                    } else if viewModel.loadMoreFailed {
                        Button("Couldn't load more movies. Try again") { Task { await viewModel.loadMore() } }
                    }
                    Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
    }
}

private struct MovieRow: View {
    let row: MovieRowModel

    var body: some View {
        HStack(spacing: 12) {
            PosterImage(url: row.posterURL)
                .frame(width: 60, height: 90)
                .clipShape(.rect(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(row.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label {
                    Text(row.ratingText)
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                .font(.subheadline)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }
}

private struct PosterImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty where url != nil:
                placeholder { ProgressView() }
            default:
                placeholder {
                    Image(systemName: "film")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func placeholder(@ViewBuilder _ content: () -> some View) -> some View {
        Rectangle()
            .fill(.quaternary)
            .overlay(content())
    }
}

private extension MovieListViewModel.MovieListError {
    var title: LocalizedStringKey {
        switch self {
        case .offline: "You're offline"
        case .missingAPIKey: "TMDB API key missing"
        case .generic: "Couldn't load movies"
        }
    }

    var message: LocalizedStringKey {
        switch self {
        case .offline: "Check your connection and try again."
        case .missingAPIKey: "Add your key to Config/Secrets.xcconfig and rebuild."
        case .generic: "Something went wrong. Please try again."
        }
    }

    var systemImage: String {
        switch self {
        case .offline: "wifi.slash"
        case .missingAPIKey: "key"
        case .generic: "exclamationmark.triangle"
        }
    }
}

#if DEBUG
#Preview {
    let service = MoviesServiceSpyingStub()
    service.popularResultToBeReturned = .success(.fixture(
        movies: (1...10).map { .fixture(id: $0, title: "Preview Movie \($0)") },
        totalPages: 3
    ))
    return MovieListView(coordinator: MovieListCoordinator(service: service, outputs: MovieListFeatureOutputs()))
}
#endif
