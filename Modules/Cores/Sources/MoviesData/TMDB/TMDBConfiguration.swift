import Foundation

/// How to reach TMDB. The API key comes from the app's configuration and is never committed.
public struct TMDBConfiguration: Sendable {
    public let apiKey: String
    public let baseURL: URL
    public let imageBaseURL: URL
    public let language: String

    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.themoviedb.org/3")!,
        imageBaseURL: URL = URL(string: "https://image.tmdb.org/t/p/w342")!,
        language: String = "en-US"
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.imageBaseURL = imageBaseURL
        self.language = language
    }
}
