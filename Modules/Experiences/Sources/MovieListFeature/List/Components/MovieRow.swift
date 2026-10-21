import MoviesDomainInterface
import SwiftUI

struct MovieRow: View {
    let row: MovieRowModel

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension MovieRow {
    var content: some View {
        HStack(spacing: 12) {
            RemoteImage(url: row.posterURL)
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

#if DEBUG
#Preview {
    List {
        MovieRow(row: MovieRowModel(movie: .fixture()))
        MovieRow(row: MovieRowModel(movie: .fixture(id: 2, title: "Untitled Project", releaseDate: nil, rating: 0)))
    }
    .listStyle(.plain)
}
#endif
