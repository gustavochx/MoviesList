import MoviesDomainInterface
import SwiftUI

struct MovieRowsList: View {
    let viewModel: MovieListViewModel
    let rows: [MovieRowModel]
    let onSelect: (Movie.ID) -> Void

    var body: some View {
        List {
            content
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
    }
}

// MARK: UI Building Blocks
private extension MovieRowsList {
    var content: some View {
        Section {
            rowsSection
        } footer: {
            MovieListFooter(viewModel: viewModel)
        }
    }

    var rowsSection: some View {
        ForEach(rows) { row in
            Button { onSelect(row.id) } label: {
                MovieRow(row: row)
            }
            .foregroundStyle(.primary)
            .task { await viewModel.loadMoreIfNeeded(after: row) }
        }
    }
}
