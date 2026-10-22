import Foundation
@testable import MoviesData
import MoviesDomainInterface
import Testing

@Suite struct TMDBMovieRepositoryTests {
    // MARK: - Mapping

    @Test func popularMapsTheResponse() async throws {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("popular"), 200)))

        let page = try await sut.popular(page: 1)

        #expect(page.page == 1)
        #expect(page.totalPages == 500)
        let dune = try #require(page.movies.first)
        #expect(dune.id == 693134)
        #expect(dune.title == "Dune: Part Two")
        #expect(dune.rating == 8.2)
        #expect(dune.posterURL?.absoluteString == "https://image.tmdb.org/t/p/w342/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg")
        #expect(dune.releaseDate == Movie.fixture().releaseDate)
    }

    @Test func missingDateAndPosterBecomeNil() async throws {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("popular"), 200)))

        let untitled = try #require(try await sut.popular(page: 1).movies.last)

        #expect(untitled.releaseDate == nil)
        #expect(untitled.posterURL == nil)
        #expect(untitled.rating == 0)
    }

    // MARK: - Requests

    @Test func popularRequestsThePopularEndpoint() async throws {
        let (sut, client) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("popular"), 200)))

        _ = try await sut.popular(page: 3)

        let request = try #require(client.requests.first)
        #expect(request.url?.path() == "/3/movie/popular")
        #expect(TMDBTestSupport.queryItems(request) == ["page": "3", "language": "en-US", "api_key": "test-key"])
    }

    @Test func searchEncodesTheQuery() async throws {
        let (sut, client) = TMDBTestSupport.makeSUT(.success((try TMDBTestSupport.fixture("popular"), 200)))

        _ = try await sut.search("star wars & co", page: 2)

        let request = try #require(client.requests.first)
        #expect(request.url?.path() == "/3/search/movie")
        #expect(TMDBTestSupport.queryItems(request)["query"] == "star wars & co")
        #expect(TMDBTestSupport.queryItems(request)["page"] == "2")
        #expect(TMDBTestSupport.queryItems(request)["include_adult"] == "false")
    }

    // MARK: - Errors

    @Test(arguments: [(401, MoviesError.unauthorized), (404, .unavailable), (500, .unavailable)])
    func httpErrorsAreMapped(status: Int, expected: MoviesError) async {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((Data(), status)))

        await #expect(throws: expected) { try await sut.popular(page: 1) }
    }

    @Test func offlineIsMapped() async {
        let (sut, _) = TMDBTestSupport.makeSUT(.failure(URLError(.notConnectedToInternet)))

        await #expect(throws: MoviesError.offline) { try await sut.popular(page: 1) }
    }

    @Test func cancelledRequestsStayCancellations() async {
        let (sut, _) = TMDBTestSupport.makeSUT(.failure(URLError(.cancelled)))

        await #expect(throws: CancellationError.self) { try await sut.popular(page: 1) }
    }

    @Test func otherTransportErrorsAreUnavailable() async {
        let (sut, _) = TMDBTestSupport.makeSUT(.failure(URLError(.timedOut)))

        await #expect(throws: MoviesError.unavailable) { try await sut.popular(page: 1) }
    }

    @Test func malformedJSONIsUnavailable() async {
        let (sut, _) = TMDBTestSupport.makeSUT(.success((Data("{\"nope\":1}".utf8), 200)))

        await #expect(throws: MoviesError.unavailable) { try await sut.popular(page: 1) }
    }

    @Test func emptyAPIKeyFailsWithoutCallingTheNetwork() async {
        let (sut, client) = TMDBTestSupport.makeSUT(.success((Data(), 200)), apiKey: "")

        await #expect(throws: MoviesError.unauthorized) { try await sut.search("dune", page: 1) }

        #expect(client.requests.isEmpty)
    }
}
