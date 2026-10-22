import Testing
@testable import DesignSystem

@Suite("ErrorStateView")
struct ErrorStateViewTests {
    @Test func retryInvokesCallerActionExactlyOnce() {
        var retryCount = 0
        let view = ErrorStateView(title: "Title", message: "Message", systemImage: "wifi.slash") {
            retryCount += 1
        }

        view.retry()

        #expect(retryCount == 1)
    }
}
