/// One page of a paginated movie list.
public struct MoviesPage: Equatable, Sendable {
    public let movies: [Movie]
    /// 1-based page number.
    public let page: Int
    public let totalPages: Int

    public init(movies: [Movie], page: Int, totalPages: Int) {
        self.movies = movies
        self.page = page
        self.totalPages = totalPages
    }

    public var hasMore: Bool {
        page < totalPages
    }
}

#if DEBUG
extension MoviesPage {
    /// A single-page result for tests and previews.
    public static func fixture(movies: [Movie] = [.fixture()], page: Int = 1, totalPages: Int = 1) -> MoviesPage {
        MoviesPage(movies: movies, page: page, totalPages: totalPages)
    }
}
#endif
