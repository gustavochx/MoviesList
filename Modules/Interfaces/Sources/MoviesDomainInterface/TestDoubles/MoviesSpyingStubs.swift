#if DEBUG
import Foundation

/// A call made to a movies contract, recorded by the spying stubs below.
public enum MoviesCall: Equatable, Sendable {
    case popular(page: Int)
    case search(query: String, page: Int)
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

    public var calls: [MoviesCall] {
        lock.withLock { storage.calls }
    }

    public func popular(page: Int) async throws -> MoviesPage {
        try lock.withLock { try storage.record(.popular(page: page)) }
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        try lock.withLock { try storage.record(.search(query: query, page: page)) }
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

    public var calls: [MoviesCall] {
        lock.withLock { storage.calls }
    }

    public func popular(page: Int) async throws -> MoviesPage {
        try lock.withLock { try storage.record(.popular(page: page)) }
    }

    public func search(_ query: String, page: Int) async throws -> MoviesPage {
        try lock.withLock { try storage.record(.search(query: query, page: page)) }
    }
}

private struct SpyingStubStorage {
    var popularResult: Result<MoviesPage, any Error> = .success(.fixture(movies: []))
    var searchResult: Result<MoviesPage, any Error> = .success(.fixture(movies: []))
    var calls: [MoviesCall] = []

    mutating func record(_ call: MoviesCall) throws -> MoviesPage {
        calls.append(call)
        switch call {
        case .popular: return try popularResult.get()
        case .search: return try searchResult.get()
        }
    }
}
#endif
