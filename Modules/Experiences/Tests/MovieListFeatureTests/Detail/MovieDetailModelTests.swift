import Foundation
@testable import MovieListFeature
import MoviesDomainInterface
import Testing

@Suite struct MovieDetailModelTests {
    private let enUS = Locale(identifier: "en_US")

    @Test func factsLineJoinsYearRuntimeAndGenres() {
        let details = MovieDetails.fixture(runtimeMinutes: 166, genres: ["Science Fiction", "Adventure"])

        let sut = MovieDetailModel(details: details, locale: enUS)

        #expect(sut.factsLine == "2024 · 2h 46m · Science Fiction, Adventure")
    }

    @Test func shortRuntimeShowsMinutesOnly() {
        let details = MovieDetails.fixture(releaseDate: nil, runtimeMinutes: 45, genres: [])

        let sut = MovieDetailModel(details: details, locale: enUS)

        #expect(sut.factsLine == "45m")
    }

    @Test func unknownFactsAreSkipped() {
        let details = MovieDetails.fixture(releaseDate: nil, runtimeMinutes: nil, genres: [])

        let sut = MovieDetailModel(details: details, locale: enUS)

        #expect(sut.factsLine.isEmpty)
    }

    @Test func ratingShowsOneDecimalAndCompactVotes() {
        let details = MovieDetails.fixture(rating: 8.24, voteCount: 6_400)

        let sut = MovieDetailModel(details: details, locale: enUS)

        #expect(sut.ratingText == "8.2")
        #expect(sut.voteCountText == "6.4K votes")
        #expect(sut.ratingAccessibilityLabel == "Rated 8.2 out of 10 from 6.4K votes")
    }

    @Test func oneVoteIsSingular() {
        let details = MovieDetails.fixture(rating: 6, voteCount: 1)

        let sut = MovieDetailModel(details: details, locale: enUS)

        #expect(sut.voteCountText == "1 vote")
        #expect(sut.ratingAccessibilityLabel == "Rated 6.0 out of 10 from 1 vote")
    }

    @Test func noVotesMeansNotRated() {
        let details = MovieDetails.fixture(rating: 0, voteCount: 0)

        let sut = MovieDetailModel(details: details, locale: enUS)

        #expect(sut.ratingText == "Not rated")
        #expect(sut.voteCountText == nil)
        #expect(sut.ratingAccessibilityLabel == "Not rated yet")
    }
}
