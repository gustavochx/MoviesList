#if DEBUG
import Foundation

/// A call made to a movies contract, recorded by the spying stubs below.
public enum MoviesCall: Equatable, Sendable {
    case popular(page: Int)
    case search(query: String, page: Int)
    case details(id: Movie.ID)
}

/// SpyingStub for `MoviesService`: returns the configured results and records every call.
public final class MoviesServiceSpyingStub: MoviesService, @unchecked Sendable {
    // Safety: all mutable state lives in `storage`, which is only touched while holding `lock`.
    private let lock = NSLock()
    private var storage = SpyingStubStorage()

    public init() {}

    public var popularResultToBeReturned: Result<MoviesPage, any Error> {
        get { lock.withLock { storage.popularResult } }
        set { lock.withLock { storage.popularResult = newValue } }
    }

    public var searchResultToBeReturned: Result<MoviesPage, any Error> {
        get { lock.withLock { storage.searchResult } }
        set { lock.withLock { storage.searchResult = newValue } }
    }

    public var detailsResultToBeReturned: Result<MovieDetails, any Error> {
        get { lock.withLock { storage.detailsResult } }
        set { lock.withLock { storage.detailsResult = newValue } }
    }

    public var calls: [MoviesCall] {
        lock.withLock { storage.calls }
    }

    public func popular(page: Int) async throws -> MoviesPage {
        try lock.withLock { storage.calls.append(.popular(page: page)); return try storage.popularResult.get() }
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        try lock.withLock { storage.calls.append(.search(query: query, page: page)); return try storage.searchResult.get() }
    }

    public func details(id: Movie.ID) async throws -> MovieDetails {
        try lock.withLock { storage.calls.append(.details(id: id)); return try storage.detailsResult.get() }
    }
}

/// SpyingStub for `MovieRepository`: returns the configured results and records every call.
public final class MovieRepositorySpyingStub: MovieRepository, @unchecked Sendable {
    // Safety: all mutable state lives in `storage`, which is only touched while holding `lock`.
    private let lock = NSLock()
    private var storage = SpyingStubStorage()

    public init() {}

    public var popularResultToBeReturned: Result<MoviesPage, any Error> {
        get { lock.withLock { storage.popularResult } }
        set { lock.withLock { storage.popularResult = newValue } }
    }

    public var searchResultToBeReturned: Result<MoviesPage, any Error> {
        get { lock.withLock { storage.searchResult } }
        set { lock.withLock { storage.searchResult = newValue } }
    }

    public var detailsResultToBeReturned: Result<MovieDetails, any Error> {
        get { lock.withLock { storage.detailsResult } }
        set { lock.withLock { storage.detailsResult = newValue } }
    }

    public var calls: [MoviesCall] {
        lock.withLock { storage.calls }
    }

    public func popular(page: Int) async throws -> MoviesPage {
        try lock.withLock { storage.calls.append(.popular(page: page)); return try storage.popularResult.get() }
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        try lock.withLock { storage.calls.append(.search(query: query, page: page)); return try storage.searchResult.get() }
    }

    public func details(id: Movie.ID) async throws -> MovieDetails {
        try lock.withLock { storage.calls.append(.details(id: id)); return try storage.detailsResult.get() }
    }
}

private struct SpyingStubStorage {
    var popularResult: Result<MoviesPage, any Error> = .success(.fixture(movies: []))
    var searchResult: Result<MoviesPage, any Error> = .success(.fixture(movies: []))
    var detailsResult: Result<MovieDetails, any Error> = .success(.fixture())
    var calls: [MoviesCall] = []
}
#endif
