@testable import DesignSystem
import SwiftUI
import Testing

@Suite("DSColor and DSFont")
struct DSColorAndFontTests {
    @Test func ratingIsYellow() {
        #expect(DSColor.rating == Color.yellow)
    }

    @Test func primaryTextIsTheHierarchicalStyleNotAColor() {
        // HierarchicalShapeStyle isn't Equatable; the type is what keeps it following the surrounding foreground style.
        #expect(type(of: DSColor.primaryText) == HierarchicalShapeStyle.self)
    }

    @Test func secondaryTextIsTheHierarchicalStyleNotAColor() {
        // HierarchicalShapeStyle isn't Equatable; the type is what keeps it following the surrounding foreground style.
        #expect(type(of: DSColor.secondaryText) == HierarchicalShapeStyle.self)
    }

    @Test("font token matches its SwiftUI font", arguments: [
        ("screenTitle", DSFont.screenTitle, Font.title2.bold()),
        ("sectionTitle", DSFont.sectionTitle, Font.headline),
        ("meta", DSFont.meta, Font.subheadline),
        ("footnote", DSFont.footnote, Font.footnote),
        ("captionStrong", DSFont.captionStrong, Font.caption.bold()),
        ("caption2", DSFont.caption2, Font.caption2)
    ] as [(String, Font, Font)])
    func fontValue(name: String, token: Font, expected: Font) {
        #expect(token == expected, "DSFont.\(name)")
    }
}
