import Foundation
import Testing
import MoviesDomainInterface

@Suite struct MovieTests {
    @Test func valuesWithTheSameFieldsAreEqual() {
        #expect(Movie.fixture() == Movie.fixture())
    }

    @Test func valuesWithDifferentIdsAreNotEqual() {
        #expect(Movie.fixture(id: 1) != Movie.fixture(id: 2))
    }
}
