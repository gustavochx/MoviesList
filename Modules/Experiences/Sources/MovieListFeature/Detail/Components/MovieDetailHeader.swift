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
        HStack(alignment: .top, spacing: 16) {
            poster

            VStack(alignment: .leading, spacing: 6) {
                titleAndFacts
                rating
            }
        }
        .padding(.horizontal)
    }

    var poster: some View {
        RemoteImage(url: model.posterURL)
            .frame(width: 100, height: 150)
            .clipShape(.rect(cornerRadius: 8))
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var titleAndFacts: some View {
        Text(model.title)
            .font(.title2.bold())
            .accessibilityAddTraits(.isHeader)
        if let tagline = model.tagline {
            Text(tagline)
                .font(.subheadline)
                .italic()
                .foregroundStyle(.secondary)
        }
        if !model.factsLine.isEmpty {
            Text(model.factsLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    var rating: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(model.ratingText)
            if let votes = model.voteCountText {
                Text("· \(votes)")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.ratingAccessibilityLabel)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 24) {
        MovieDetailHeader(model: MovieDetailModel(details: .fixture()))
        MovieDetailHeader(model: MovieDetailModel(details: .fixture(
            title: "Untitled Project", tagline: nil, releaseDate: nil, runtimeMinutes: nil, genres: [], rating: 0, voteCount: 0
        )))
    }
}
#endif
