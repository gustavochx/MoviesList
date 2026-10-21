import MoviesDomainInterface
import SwiftUI

/// Why a screen couldn't load, reduced to what the user can act on. Shared by the list and detail screens.
enum LoadFailure: Equatable {
    case offline
    case missingAPIKey
    case generic

    init(_ error: any Error) {
        switch error as? MoviesError {
        case .offline: self = .offline
        case .unauthorized: self = .missingAPIKey
        case .notFound, .unavailable, nil: self = .generic
        }
    }
}

/// Full-screen error with a retry button. `genericTitle` names what failed to load.
struct LoadFailureView: View {
    let failure: LoadFailure
    let genericTitle: LocalizedStringKey
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }

    private var title: LocalizedStringKey {
        switch failure {
        case .offline: "You're offline"
        case .missingAPIKey: "TMDB API key missing"
        case .generic: genericTitle
        }
    }

    private var message: LocalizedStringKey {
        switch failure {
        case .offline: "Check your connection and try again."
        case .missingAPIKey: "Add your key to Config/Secrets.xcconfig and rebuild."
        case .generic: "Something went wrong. Please try again."
        }
    }

    private var systemImage: String {
        switch failure {
        case .offline: "wifi.slash"
        case .missingAPIKey: "key"
        case .generic: "exclamationmark.triangle"
        }
    }
}
