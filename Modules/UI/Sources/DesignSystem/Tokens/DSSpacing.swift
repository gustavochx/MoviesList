import SwiftUI

/// Spacing scale used for stack spacing and padding. `nonisolated` so layout code off the main actor can read it.
public enum DSSpacing {
    nonisolated public static let xxs: CGFloat = 4
    nonisolated public static let xs: CGFloat = 6
    nonisolated public static let s: CGFloat = 8
    nonisolated public static let m: CGFloat = 12
    nonisolated public static let l: CGFloat = 16
    nonisolated public static let xl: CGFloat = 20
    nonisolated public static let xxl: CGFloat = 24
}
