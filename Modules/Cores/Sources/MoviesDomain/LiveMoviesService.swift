import MoviesDomainInterface

/// Live implementation of `MoviesService`. Only the composition root and tests should import this module.
public final class LiveMoviesService: MoviesService {
    private let repository: MovieRepository

    public init(repository: MovieRepository) {
        self.repository = repository
    }

    public func popular(page: Int) async throws -> MoviesPage {
        try await repository.popular(page: page).withoutUntitledMovies()
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return try await popular(page: page) }
        return try await repository.search(query, page: page).withoutUntitledMovies()
    }

    /// The cast is trimmed to the top-billed members that have a name. A person billed for several roles
    /// appears once, at their first billing, with the roles joined ("Role A / Role B").
    public func details(id: Movie.ID) async throws -> MovieDetails {
        let details = try await repository.details(id: id)
        let named = details.cast.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let cast = Self.mergingRepeatedPeople(named).prefix(Self.castLimit)
        return MovieDetails(
            id: details.id, title: details.title, tagline: details.tagline, overview: details.overview,
            releaseDate: details.releaseDate, runtimeMinutes: details.runtimeMinutes, genres: details.genres,
            rating: details.rating, voteCount: details.voteCount, posterURL: details.posterURL,
            backdropURL: details.backdropURL, cast: Array(cast)
        )
    }

    private static func mergingRepeatedPeople(_ cast: [CastMember]) -> [CastMember] {
        var order: [CastMember.ID] = []
        var byID: [CastMember.ID: CastMember] = [:]
        for member in cast {
            guard let existing = byID[member.id] else {
                order.append(member.id)
                byID[member.id] = member
                continue
            }
            let roles = [existing.character, member.character].filter { !$0.isEmpty }
            byID[member.id] = CastMember(
                id: existing.id,
                name: existing.name,
                character: roles.joined(separator: " / "),
                profileURL: existing.profileURL ?? member.profileURL
            )
        }
        return order.compactMap { byID[$0] }
    }

    /// How many top-billed cast members `details(id:)` keeps.
    public static let castLimit = 15
}

private extension MoviesPage {
    /// Movies without a title can't be shown or searched for, so the domain drops them.
    func withoutUntitledMovies() -> MoviesPage {
        MoviesPage(
            movies: movies.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            page: page,
            totalPages: totalPages
        )
    }
}
