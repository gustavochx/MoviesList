import SwiftUI

/// Load-more progress or retry, plus the TMDB attribution. Its own view so load-more state changes
/// re-evaluate only the footer, not the rows above it.
struct MovieListFooter: View {
    let viewModel: MovieListViewModel

    var body: some View {
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
