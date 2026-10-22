import SwiftUI

/// Semantic colors and fills.
public enum DSColor {
    /// The rating star.
    nonisolated public static let rating: Color = .yellow
    /// Primary text. A hierarchical style, not `Color.primary`, so it follows the surrounding foreground style
    /// (tints, selection, materials) the way `.foregroundStyle(.primary)` does.
    nonisolated public static let primaryText: HierarchicalShapeStyle = .primary
    /// Secondary text. A hierarchical style, not `Color.secondary`, so it follows the surrounding foreground style
    /// (tints, selection, materials) the way `.foregroundStyle(.secondary)` does.
    nonisolated public static let secondaryText: HierarchicalShapeStyle = .secondary
    /// Fill behind images that are loading or missing (a hierarchical style, not a `Color`).
    nonisolated public static let placeholder: HierarchicalShapeStyle = .quaternary
}
