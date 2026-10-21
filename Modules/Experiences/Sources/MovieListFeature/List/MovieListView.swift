import MoviesDomainInterface
import SwiftUI

struct MovieListView: View {
    @Bindable var coordinator: MovieListCoordinator
    @State private var searchText = ""

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension MovieListView {
    var content: some View {
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
