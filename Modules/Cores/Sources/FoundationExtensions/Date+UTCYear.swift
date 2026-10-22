import Foundation

public extension Date {
    /// The calendar year in UTC, e.g. for release dates that TMDB reports (and we parse) in UTC.
    var utcYear: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return String(calendar.component(.year, from: self))
    }
}
