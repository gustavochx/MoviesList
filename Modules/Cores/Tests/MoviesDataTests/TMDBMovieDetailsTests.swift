import Foundation
@testable import MoviesData
import MoviesDomainInterface
import Testing

@Suite struct TMDBMovieDetailsTests {
    @Test func requestsTheMovieWithItsCredits() async throws {
        let (sut, client) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("details"), 200)))

        _ = try await sut.details(id: 693134)

        let request = try #require(client.requests.first)
        let items = URLComponents(url: try #require(request.url), resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(request.url?.path() == "/3/movie/693134")
        #expect(items.contains(URLQueryItem(name: "append_to_response", value: "credits")))
        #expect(items.contains(URLQueryItem(name: "api_key", value: "test-key")))
    }

    @Test func mapsTheResponse() async throws {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("details"), 200)))

        let details = try await sut.details(id: 693134)

        #expect(details.title == "Dune: Part Two")
        #expect(details.tagline == "Long live the fighters.")
        #expect(details.runtimeMinutes == 167)
        #expect(details.genres == ["Science Fiction", "Adventure"])
        #expect(details.rating == 8.142)
        #expect(details.voteCount == 8782)
        #expect(details.releaseDate == Movie.fixture().releaseDate)
        #expect(details.posterURL?.absoluteString == "https://image.tmdb.org/t/p/w342/6izwz7rsy95ARzTR3poZ8H6c5pp.jpg")
        #expect(details.backdropURL?.absoluteString == "https://image.tmdb.org/t/p/w780/eZ239CUp1d6OryZEBPnO2n87gMG.jpg")
    }

    @Test func mapsTheCastInBillingOrder() async throws {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("details"), 200)))

        let cast = try await sut.details(id: 693134).cast

        #expect(cast.map(\.name) == ["Timothée Chalamet", "Unknown Extra"])
        #expect(cast.first?.profileURL?.absoluteString == "https://image.tmdb.org/t/p/w185/dFxpwRpmzpVfP1zjluH68DeQhyj.jpg")
        #expect(cast.last?.character == "")
        #expect(cast.last?.profileURL == nil)
    }

    @Test func missingOptionalFieldsBecomeNil() async throws {
        let body = Data(#"{"id": 1, "title": "Unknown", "tagline": "", "runtime": 0, "poster_path": null, "backdrop_path": null}"#.utf8)
        let (sut, _) = TMDBTestSupport.makeSUT(.success((body, 200)))

        let details = try await sut.details(id: 1)

        #expect(details.tagline == nil)
        #expect(details.runtimeMinutes == nil)
        #expect(details.overview.isEmpty)
        #expect(details.genres.isEmpty)
        #expect(details.cast.isEmpty)
        #expect(details.backdropURL == nil)
    }

    @Test func missingMovieIsNotFound() async {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((Data(), 404)))

        await #expect(throws: MoviesError.notFound) { try await sut.details(id: 999_999_999) }
    }
}
