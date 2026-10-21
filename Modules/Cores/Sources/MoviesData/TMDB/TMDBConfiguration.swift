import Foundation

/// How to reach TMDB. The API key comes from the app's configuration and is never committed.
public struct TMDBConfiguration: Sendable {
    public let apiKey: String
    public let baseURL: URL
    /// Root of TMDB's image CDN; each image type appends its own size (`w342`, `w780`, ...).
    public let imageRootURL: URL
    public let language: String

    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.themoviedb.org/3")!,
        imageRootURL: URL = URL(string: "https://image.tmdb.org/t/p")!,
        language: String = "en-US"
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.imageRootURL = imageRootURL
        self.language = language
    }
}
