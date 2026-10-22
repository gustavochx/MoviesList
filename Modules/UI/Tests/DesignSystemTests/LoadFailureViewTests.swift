@testable import DesignSystem
import Testing

@Suite("LoadFailureView.Reason")
struct LoadFailureViewTests {
    @Test(arguments: [
        (LoadFailureView.Reason.offline, "wifi.slash"),
        (LoadFailureView.Reason.generic(title: "Title"), "exclamationmark.triangle"),
        (LoadFailureView.Reason.custom(title: "Title", message: "Message", systemImage: "key"), "key")
    ])
    func reasonResolvesToItsSystemImage(reason: LoadFailureView.Reason, expected: String) {
        #expect(reason.systemImage == expected)
    }
}
