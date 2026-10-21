import Testing
import MoviesDomainInterface

@Suite struct MoviesPageTests {
    @Test(arguments: [(1, 3, true), (3, 3, false), (1, 1, false), (1, 0, false)])
    func hasMoreOnlyBeforeTheLastPage(page: Int, totalPages: Int, expected: Bool) {
        #expect(MoviesPage.fixture(page: page, totalPages: totalPages).hasMore == expected)
    }
}
