import Testing
@testable import DesignSystem

@Suite("RatingView")
struct RatingViewTests {
    @Test func storesValueAndDetail() {
        let view = RatingView(value: "8.1", detail: "12,345 votes")

        #expect(view.value == "8.1")
        #expect(view.detail == "12,345 votes")
    }

    @Test func detailDefaultsToNil() {
        let view = RatingView(value: "8.1")

        #expect(view.detail == nil)
    }
}
