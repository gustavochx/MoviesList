import DesignSystem
@testable import MovieListFeature
import Testing

@Suite("LoadFailure")
struct LoadFailureTests {
    @Test(arguments: [
        (LoadFailure.offline, LoadFailureView.Reason.offline),
        (LoadFailure.generic, LoadFailureView.Reason.generic(title: "Couldn't load")),
        (
            LoadFailure.missingAPIKey,
            LoadFailureView.Reason.custom(
                title: "TMDB API key missing",
                message: "Add your key to Config/Secrets.xcconfig and rebuild.",
                systemImage: "key"
            )
        )
    ])
    func mapsToReason(failure: LoadFailure, expected: LoadFailureView.Reason) {
        #expect(failure.reason(genericTitle: "Couldn't load") == expected)
    }
}
