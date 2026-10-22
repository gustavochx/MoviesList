import Foundation
import FoundationExtensions
import MoviesDomainInterface

/// What the detail screen displays. Formatting lives here so views stay dumb and it can be tested.
struct MovieDetailModel: Equatable {
    let title: String
    let tagline: String?
    let overview: String
    /// "2024 · 2h 46m · Science Fiction, Adventure", skipping unknown parts.
    let factsLine: String
    /// "8.2", or "Not rated" when nobody has voted yet.
    let ratingText: String
    /// "6.4K votes", or nil when there are none.
    let voteCountText: String?
    let posterURL: URL?
    let backdropURL: URL?
    let cast: [CastMember]
    let ratingAccessibilityLabel: String

    init(details: MovieDetails, locale: Locale = .current) {
        title = details.title
        tagline = details.tagline
        overview = details.overview
        posterURL = details.posterURL
        backdropURL = details.backdropURL
        cast = details.cast

        let runtime = details.runtimeMinutes.map { minutes in
            Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .narrow).locale(locale))
        }
        let genres = details.genres.isEmpty ? nil : details.genres.formatted(.list(type: .and, width: .narrow).locale(locale))
        factsLine = [details.releaseDate?.utcYear, runtime, genres]
            .compactMap { $0 }
            .joined(separator: " · ")

        let isRated = details.voteCount > 0 && details.rating > 0
        ratingText = isRated
            ? details.rating.formatted(.number.precision(.fractionLength(1)).locale(locale))
            : String(localized: "Not rated")
        let votes = details.voteCount.formatted(.number.notation(.compactName).locale(locale))
        // Only an exact count of one is singular; compact counts ("1.2K") always read as plural.
        voteCountText = !isRated ? nil
            : details.voteCount == 1 ? String(localized: "1 vote") : String(localized: "\(votes) votes")
        ratingAccessibilityLabel = !isRated ? String(localized: "Not rated yet")
            : details.voteCount == 1 ? String(localized: "Rated \(ratingText) out of 10 from 1 vote")
            : String(localized: "Rated \(ratingText) out of 10 from \(votes) votes")
    }
}
