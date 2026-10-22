import DesignSystem
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
        HStack(spacing: DSSpacing.m) {
            ArtworkImage(
                url: row.posterURL,
                size: CGSize(width: 60, height: 90),
                cornerRadius: DSRadius.small,
                fallbackSymbol: "film"
            )

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(row.title)
                    .font(DSFont.sectionTitle)
                    .lineLimit(2)
                Text(row.year)
                    .font(DSFont.meta)
                    .foregroundStyle(DSColor.secondaryText)
                RatingView(value: row.ratingText)
                    .font(DSFont.meta)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, DSSpacing.xxs)
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
