import SwiftUI
import Testing
@testable import DesignSystem

@Suite("DSSpacing")
struct DSSpacingTests {
    @Test("token keeps its original literal value", arguments: [
        ("xxs", DSSpacing.xxs, 4),
        ("xs", DSSpacing.xs, 6),
        ("s", DSSpacing.s, 8),
        ("m", DSSpacing.m, 12),
        ("l", DSSpacing.l, 16),
        ("xl", DSSpacing.xl, 20),
        ("xxl", DSSpacing.xxl, 24)
    ] as [(String, CGFloat, CGFloat)])
    func tokenValue(name: String, token: CGFloat, literal: CGFloat) {
        #expect(token == literal, "DSSpacing.\(name)")
    }
}
