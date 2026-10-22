import Foundation
@testable import MoviesData
import Testing

/// Shared plumbing for the TMDB repository suites: JSON fixtures from this target's bundle
/// and a repository wired to an `HTTPClientSpyingStub`.
enum TMDBTestSupport {
    static func fixture(_ name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }

    static func makeSUT(
        _ response: Result<(body: Data, statusCode: Int), any Error>,
        apiKey: String = "test-key"
    ) -> (TMDBMovieRepository, HTTPClientSpyingStub) {
        let client = HTTPClientSpyingStub(response)
        return (TMDBMovieRepository(configuration: TMDBConfiguration(apiKey: apiKey), client: client), client)
    }

    static func queryItems(_ request: URLRequest) -> [String: String] {
        let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }
}
