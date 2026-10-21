import Foundation
import MoviesDomainInterface

/// Turns TMDB DTOs into domain models.
struct MovieMapper: Sendable {
    let imageBaseURL: URL

    func page(from dto: TMDBPageDTO) -> MoviesPage {
        MoviesPage(movies: dto.results.map(movie(from:)), page: dto.page, totalPages: dto.totalPages)
    }

    func movie(from dto: TMDBMovieDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            releaseDate: dto.releaseDate.flatMap(Self.date(from:)),
            rating: dto.voteAverage ?? 0,
            posterURL: dto.posterPath.map { imageBaseURL.appending(path: $0) }
        )
    }

    static func date(from string: String) -> Date? {
        try? Date(string, strategy: Date.ISO8601FormatStyle().year().month().day())
    }
}
