import Foundation
import Testing
import MoviesData
import MoviesDomain
import MoviesDomainInterface

/// Integration: the domain service on top of the real TMDB repository, with only the HTTP layer stubbed.
@Suite(.tags(.integration))
struct MoviesIntegrationTests {
    private let client = HTTPClientSpyingStub()

    private var sut: LiveMoviesService {
        LiveMoviesService(repository: TMDBMovieRepository(configuration: TMDBConfiguration(apiKey: "test-key"), client: client))
    }

    private static let searchResponse = Data("""
    {
      "page": 1,
      "total_pages": 2,
      "results": [
        { "id": 438631, "title": "Dune", "release_date": "2021-09-15", "vote_average": 7.8, "poster_path": "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg" },
        { "id": 7, "title": "  ", "release_date": "", "vote_average": 0, "poster_path": null }
      ]
    }
    """.utf8)

    @Test func searchReturnsMappedMoviesWithoutUntitledOnes() async throws {
        client.responseToBeReturned = .success((Self.searchResponse, 200))

        let page = try await sut.search("  dune  ", page: 1)

        #expect(page.movies.map(\.title) == ["Dune"])
        #expect(page.movies.first?.posterURL?.absoluteString == "https://image.tmdb.org/t/p/w342/d5NXSklXo0qyIYkgV94XAgMIckC.jpg")
        #expect(page.hasMore)
        let request = try #require(client.requests.first)
        #expect(request.url?.path() == "/3/search/movie")
        #expect(request.url?.query()?.contains("query=dune&") == true)
    }

    @Test func blankSearchHitsThePopularEndpoint() async throws {
        client.responseToBeReturned = .success((Self.searchResponse, 200))

        _ = try await sut.search("   ", page: 1)

        #expect(try #require(client.requests.first).url?.path() == "/3/movie/popular")
    }

    @Test func detailsAreMappedWithTheCastTrimmed() async throws {
        let response: [String: Any] = [
            "id": 438631,
            "title": "Dune",
            "runtime": 155,
            "genres": [["id": 1, "name": "Drama"]],
            "vote_average": 7.8,
            "vote_count": 12000,
            "credits": ["cast": (1...20).map { ["id": $0, "name": "Actor \($0)", "character": "Role"] }]
        ]
        client.responseToBeReturned = .success((try JSONSerialization.data(withJSONObject: response), 200))

        let details = try await sut.details(id: 438631)

        #expect(details.title == "Dune")
        #expect(details.runtimeMinutes == 155)
        #expect(details.genres == ["Drama"])
        #expect(details.cast.count == LiveMoviesService.castLimit)
        #expect(try #require(client.requests.first).url?.path() == "/3/movie/438631")
    }

    @Test func missingMovieSurfacesAsNotFound() async {
        client.responseToBeReturned = .success((Data(), 404))

        await #expect(throws: MoviesError.notFound) { try await sut.details(id: 1) }
    }

    @Test func rejectedKeySurfacesAsUnauthorized() async {
        client.responseToBeReturned = .success((Data(), 401))

        await #expect(throws: MoviesError.unauthorized) { try await sut.popular(page: 1) }
    }
}

extension Tag {
    @Tag static var integration: Self
}
