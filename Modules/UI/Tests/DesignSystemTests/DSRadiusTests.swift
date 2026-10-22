@testable import DesignSystem
import SwiftUI
import Testing

@Suite("DSRadius")
struct DSRadiusTests {
    @Test("token keeps its original literal value", arguments: [
        ("small", DSRadius.small, 6),
        ("medium", DSRadius.medium, 8)
    ] as [(String, CGFloat, CGFloat)])
    func tokenValue(name: String, token: CGFloat, literal: CGFloat) {
        #expect(token == literal, "DSRadius.\(name)")
    }
}
