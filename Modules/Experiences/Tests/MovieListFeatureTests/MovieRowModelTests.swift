import Foundation
import MoviesDomainInterface
import Testing
@testable import MovieListFeature

@Suite struct MovieRowModelTests {
    private let enUS = Locale(identifier: "en_US")

    @Test func formatsYearAndRating() {
        let movie = Movie.fixture(title: "Dune: Part Two", rating: 8.24)

        let sut = MovieRowModel(movie: movie, locale: enUS)

        #expect(sut.year == "2024")
        #expect(sut.ratingText == "8.2")
        #expect(sut.accessibilityLabel == "Dune: Part Two, 2024, rated 8.2 out of 10")
    }

    @Test func unknownReleaseDateShowsADash() {
        let movie = Movie.fixture(title: "Untitled", releaseDate: nil)

        let sut = MovieRowModel(movie: movie, locale: enUS)

        #expect(sut.year == "—")
        #expect(sut.accessibilityLabel.hasPrefix("Untitled, release year unknown"))
    }

    @Test func zeroRatingMeansNotRated() {
        let movie = Movie.fixture(title: "Avengers: Doomsday", releaseDate: nil, rating: 0)

        let sut = MovieRowModel(movie: movie, locale: enUS)

        #expect(sut.ratingText == "Not rated")
        #expect(sut.accessibilityLabel == "Avengers: Doomsday, release year unknown, not rated yet")
    }

    @Test func newYearsEveInUTCKeepsItsYear() throws {
        let movie = Movie.fixture(releaseDate: try Date("2023-12-31T00:00:00Z", strategy: .iso8601))

        let sut = MovieRowModel(movie: movie, locale: enUS)

        #expect(sut.year == "2023")
    }
}
