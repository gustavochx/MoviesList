import Foundation
import Testing
@testable import MoviesDomainInterface

@Suite struct MovieTests {
    @Test func valuesWithTheSameFieldsAreEqual() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 100)

        #expect(Movie(id: id, createdAt: date) == Movie(id: id, createdAt: date))
    }

    @Test func valuesWithDifferentIdsAreNotEqual() {
        let date = Date(timeIntervalSince1970: 100)

        #expect(Movie(createdAt: date) != Movie(createdAt: date))
    }
}
