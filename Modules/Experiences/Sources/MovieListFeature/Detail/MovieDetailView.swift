import MoviesDomainInterface
import SwiftUI

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
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(model):
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Backdrop(url: model.backdropURL)
                    DetailHeader(model: model)
                    if !model.overview.isEmpty {
                        DetailSection("Overview") {
                            Text(model.overview)
                                .padding(.horizontal)
                        }
                    }
                    if !model.cast.isEmpty {
                        DetailSection("Top Cast") {
                            CastRail(cast: model.cast)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
        case .notFound:
            ContentUnavailableView(
                "Movie not found",
                systemImage: "film",
                description: Text("It may have been removed from TMDB.")
            )
        case let .failed(failure):
            LoadFailureView(failure: failure, genericTitle: "Couldn't load this movie") {
                Task { await viewModel.retry() }
            }
        }
    }
}

private struct Backdrop: View {
    let url: URL?

    var body: some View {
        // A fixed-height clear frame keeps the filled image from widening the layout.
        Color.clear
            .frame(height: 220)
            .overlay { RemoteImage(url: url, fallbackSymbol: "photo") }
            .clipped()
            .accessibilityHidden(true)
    }
}

private struct DetailHeader: View {
    let model: MovieDetailModel

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RemoteImage(url: model.posterURL)
                .frame(width: 100, height: 150)
                .clipShape(.rect(cornerRadius: 8))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
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
        .padding(.horizontal)
    }
}

private struct DetailSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            content
        }
    }
}

private struct CastRail: View {
    let cast: [CastMember]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 12) {
                ForEach(cast) { member in
                    CastCard(member: member)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

private struct CastCard: View {
    let member: CastMember

    var body: some View {
        VStack(spacing: 6) {
            RemoteImage(url: member.profileURL, fallbackSymbol: "person.fill")
                .frame(width: 72, height: 72)
                .clipShape(.circle)
            Text(member.name)
                .font(.caption.bold())
                .lineLimit(2)
            if !member.character.isEmpty {
                Text(member.character)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .multilineTextAlignment(.center)
        .frame(width: 88)
        .accessibilityElement(children: .combine)
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
