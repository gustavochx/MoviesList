@testable import DesignSystem
import Testing

@Suite("EmptyStateView")
struct EmptyStateViewTests {
    @Test func actionInvokesCallerClosureExactlyOnce() throws {
        var actionCount = 0
        let view = EmptyStateView(title: "Title", message: "Message", systemImage: "tray") {
            actionCount += 1
        }

        let action = try #require(view.action)
        action()

        #expect(actionCount == 1)
    }

    @Test func actionTitleDefaultsToTryAgain() {
        let view = EmptyStateView(title: "Title", message: "Message", systemImage: "tray") {}

        #expect(view.actionTitle == "Try Again")
    }

    @Test func actionIsNilWhenNoneIsGiven() {
        let view = EmptyStateView(title: "Title", message: "Message", systemImage: "tray")

        #expect(view.action == nil)
    }
}
