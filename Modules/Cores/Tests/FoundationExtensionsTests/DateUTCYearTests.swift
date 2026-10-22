import Foundation
import FoundationExtensions
import Testing

@Suite("Date.utcYear")
struct DateUTCYearTests {
    @Test(arguments: [
        ("2023-12-31T00:00:00Z", "2023"),
        ("2023-12-31T23:59:00Z", "2023"),
        ("2024-01-01T00:00:00Z", "2024")
    ])
    func readsTheYearInUTC(iso: String, expected: String) throws {
        let date = try Date(iso, strategy: .iso8601)

        #expect(date.utcYear == expected)
    }

    @Test func readsTheYearOfAnEpochDate() {
        #expect(Date(timeIntervalSince1970: 1_708_992_000).utcYear == "2024")
    }
}
