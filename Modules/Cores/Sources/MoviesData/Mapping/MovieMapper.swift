import Foundation
import MoviesDomainInterface

/// Turns TMDB DTOs into domain models.
struct MovieMapper: Sendable {
    let imageRootURL: URL

    func page(from dto: TMDBPageDTO) -> MoviesPage {
        MoviesPage(movies: dto.results.map(movie(from:)), page: dto.page, totalPages: dto.totalPages)
    }

    func movie(from dto: TMDBMovieDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            releaseDate: dto.releaseDate.flatMap(Self.date(from:)),
            rating: dto.voteAverage ?? 0,
            posterURL: image(dto.posterPath, size: .poster)
        )
    }

    func details(from dto: TMDBMovieDetailsDTO) -> MovieDetails {
        MovieDetails(
            id: dto.id,
            title: dto.title,
            tagline: dto.tagline.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 },
            overview: dto.overview ?? "",
            releaseDate: dto.releaseDate.flatMap(Self.date(from:)),
            runtimeMinutes: dto.runtime.flatMap { $0 > 0 ? $0 : nil },
            genres: dto.genres?.map(\.name) ?? [],
            rating: dto.voteAverage ?? 0,
            voteCount: dto.voteCount ?? 0,
            posterURL: image(dto.posterPath, size: .poster),
            backdropURL: image(dto.backdropPath, size: .backdrop),
            cast: (dto.credits?.cast ?? []).map {
                CastMember(id: $0.id, name: $0.name, character: $0.character ?? "", profileURL: image($0.profilePath, size: .profile))
            }
        )
    }

    enum ImageSize: String {
        case poster = "w342"
        case backdrop = "w780"
        case profile = "w185"
    }

    func image(_ path: String?, size: ImageSize) -> URL? {
        path.map { imageRootURL.appending(path: size.rawValue).appending(path: $0) }
    }

    static func date(from string: String) -> Date? {
        try? Date(string, strategy: Date.ISO8601FormatStyle().year().month().day())
    }
}
