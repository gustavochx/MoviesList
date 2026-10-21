import Foundation
import MoviesDomainInterface

/// What one row of the list displays. Formatting lives here so views stay dumb and it can be tested.
struct MovieRowModel: Identifiable, Equatable {
    let id: Movie.ID
    let title: String
    /// "2024", or "—" when the release date is unknown.
    let year: String
    /// Rating out of 10 with one decimal, e.g. "7.8", or "Not rated" when nobody has voted yet.
    let ratingText: String
    let posterURL: URL?
    let accessibilityLabel: String

    init(movie: Movie, locale: Locale = .current) {
        id = movie.id
        title = movie.title
        posterURL = movie.posterURL
        // TMDB reports 0 for movies without votes (typically unreleased ones).
        let isRated = movie.rating > 0
        ratingText = isRated
            ? movie.rating.formatted(.number.precision(.fractionLength(1)).locale(locale))
            : String(localized: "Not rated")

        let releaseYear = ReleaseYear.string(from: movie.releaseDate)
        year = releaseYear ?? "—"

        let yearPart = releaseYear ?? String(localized: "release year unknown")
        accessibilityLabel = isRated
            ? String(localized: "\(movie.title), \(yearPart), rated \(ratingText) out of 10")
            : String(localized: "\(movie.title), \(yearPart), not rated yet")
    }
}
