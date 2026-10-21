import Foundation

enum ReleaseYear {
    /// The release year as TMDB reports it. Dates are parsed in UTC, so the year is read in UTC too.
    static func string(from date: Date?) -> String? {
        guard let date else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return String(calendar.component(.year, from: date))
    }
}
