import DesignSystem
import MoviesDomainInterface
import SwiftUI

/// Poster next to the title, tagline, facts line and rating.
struct MovieDetailHeader: View {
    let model: MovieDetailModel

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension MovieDetailHeader {
    var content: some View {
        HStack(alignment: .top, spacing: DSSpacing.l) {
            poster

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                titleAndFacts
                rating
            }
        }
        .padding(.horizontal, DSSpacing.l)
    }

    var poster: some View {
        ArtworkImage(
            url: model.posterURL,
            size: CGSize(width: 100, height: 150),
            cornerRadius: DSRadius.medium,
            fallbackSymbol: "film"
        )
        .accessibilityHidden(true)
    }

    @ViewBuilder
    var titleAndFacts: some View {
        Text(model.title)
            .font(DSFont.screenTitle)
            .accessibilityAddTraits(.isHeader)
        if let tagline = model.tagline {
            Text(tagline)
                .font(DSFont.meta)
                .italic()
                .foregroundStyle(DSColor.secondaryText)
        }
        if !model.factsLine.isEmpty {
            Text(model.factsLine)
                .font(DSFont.meta)
                .foregroundStyle(DSColor.secondaryText)
        }
    }

    var rating: some View {
        RatingView(value: model.ratingText, detail: model.voteCountText)
            .font(DSFont.meta)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(model.ratingAccessibilityLabel)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: DSSpacing.xxl) {
        MovieDetailHeader(model: MovieDetailModel(details: .fixture()))
        MovieDetailHeader(model: MovieDetailModel(details: .fixture(
            title: "Untitled Project", tagline: nil, releaseDate: nil, runtimeMinutes: nil, genres: [], rating: 0, voteCount: 0
        )))
    }
}
#endif
