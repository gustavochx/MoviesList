import DesignSystem
import MoviesDomainInterface
import SwiftUI

/// The movie detail screen. Unlike the list, it owns its first load (`.task`), because it has no search field
/// whose `.task(id:)` would trigger it.
struct MovieDetailView: View {
    let viewModel: MovieDetailViewModel

    var body: some View {
        content
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }
}

// MARK: UI Building Blocks
private extension MovieDetailView {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .loading:
            loading
        case let .loaded(model):
            loaded(model)
        case .notFound:
            notFound
        case let .failed(failure):
            LoadFailureView(failure: failure, genericTitle: "Couldn't load this movie") {
                Task { await viewModel.retry() }
            }
        }
    }

    var loading: some View {
        LoadingStateView()
    }

    func loaded(_ model: MovieDetailModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                MovieDetailBackdrop(url: model.backdropURL)
                MovieDetailHeader(model: model)
                if !model.overview.isEmpty {
                    TitledSection("Overview") {
                        Text(model.overview)
                            .padding(.horizontal)
                    }
                }
                if !model.cast.isEmpty {
                    TitledSection("Top Cast") {
                        CastRail(cast: model.cast)
                    }
                }
            }
            .padding(.bottom, DSSpacing.xxl)
        }
    }

    var notFound: some View {
        EmptyStateView(
            title: "Movie not found",
            message: "It may have been removed from TMDB.",
            systemImage: "film"
        )
    }
}

#if DEBUG
#Preview {
    let interactor = MovieDetailInteractorSpyingStub()
    interactor.detailsResultToBeReturned = .success(.fixture(
        cast: (1...8).map { .fixture(id: $0, name: "Actor \($0)", character: "Character \($0)") }
    ))
    return NavigationStack {
        MovieDetailView(viewModel: MovieDetailViewModel(movieID: 1, interactor: interactor))
    }
}
#endif
