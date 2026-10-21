import Foundation
import MoviesDomainInterface

/// `MovieRepository` backed by the TMDB v3 API.
/// Errors are always `MoviesError` (or `CancellationError` when the caller's task is cancelled),
/// so nothing TMDB-specific leaks past this module.
public struct TMDBMovieRepository: MovieRepository {
    private let configuration: TMDBConfiguration
    private let client: HTTPClient
    private let mapper: MovieMapper

    public init(configuration: TMDBConfiguration, client: HTTPClient = URLSession.shared) {
        self.configuration = configuration
        self.client = client
        self.mapper = MovieMapper(imageRootURL: configuration.imageRootURL)
    }

    public func popular(page: Int) async throws -> MoviesPage {
        let dto = try await fetch(TMDBPageDTO.self, path: "movie/popular", query: [URLQueryItem(name: "page", value: String(page))])
        return mapper.page(from: dto)
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        let dto = try await fetch(TMDBPageDTO.self, path: "search/movie", query: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false")
        ])
        return mapper.page(from: dto)
    }

    /// One request for the movie and its cast (`append_to_response=credits`). A missing movie is `.notFound`.
    public func details(id: Movie.ID) async throws -> MovieDetails {
        let dto = try await fetch(
            TMDBMovieDetailsDTO.self,
            path: "movie/\(id)",
            query: [URLQueryItem(name: "append_to_response", value: "credits")],
            notFound: .notFound
        )
        return mapper.details(from: dto)
    }

    func request(path: String, query: [URLQueryItem]) -> URLRequest {
        var components = URLComponents(url: configuration.baseURL.appending(path: path), resolvingAgainstBaseURL: false)!
        components.queryItems = query + [
            URLQueryItem(name: "language", value: configuration.language),
            URLQueryItem(name: "api_key", value: configuration.apiKey)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    /// `notFound` is what an HTTP 404 means for this endpoint: a missing resource, or just an unavailable list.
    private func fetch<DTO: Decodable>(
        _ type: DTO.Type,
        path: String,
        query: [URLQueryItem],
        notFound: MoviesError = .unavailable
    ) async throws -> DTO {
        guard !configuration.apiKey.isEmpty else { throw MoviesError.unauthorized }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await client.data(for: request(path: path, query: query))
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(error.code) {
            throw MoviesError.offline
        } catch {
            throw MoviesError.unavailable
        }

        switch (response as? HTTPURLResponse)?.statusCode {
        case .some(200..<300):
            break
        case .some(401):
            throw MoviesError.unauthorized
        case .some(404):
            throw notFound
        default:
            throw MoviesError.unavailable
        }

        do {
            return try JSONDecoder().decode(DTO.self, from: data)
        } catch {
            throw MoviesError.unavailable
        }
    }
}
