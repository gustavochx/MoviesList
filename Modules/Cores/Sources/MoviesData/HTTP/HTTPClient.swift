import Foundation

/// The one thing the data layer needs from the network. `URLSession` conforms; tests use a fake.
public protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

#if DEBUG
/// SpyingStub for `HTTPClient`: answers with the configured body and status code, and records every request.
public final class HTTPClientSpyingStub: HTTPClient, @unchecked Sendable {
    // Safety: `response` and `recorded` are only touched while holding `lock`.
    private let lock = NSLock()
    private var response: Result<(body: Data, statusCode: Int), any Error>
    private var recorded: [URLRequest] = []

    public init(_ response: Result<(body: Data, statusCode: Int), any Error> = .success((Data(), 200))) {
        self.response = response
    }

    public var responseToBeReturned: Result<(body: Data, statusCode: Int), any Error> {
        get { lock.withLock { response } }
        set { lock.withLock { response = newValue } }
    }

    public var requests: [URLRequest] {
        lock.withLock { recorded }
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let result = lock.withLock {
            recorded.append(request)
            return response
        }
        let (body, statusCode) = try result.get()
        return (body, HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!)
    }
}
#endif
