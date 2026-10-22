import DesignSystem
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

extension LoadFailure {
    /// The design-system reason to show. `genericTitle` names what failed to load; the TMDB key copy lives here, not in `DesignSystem`.
    func reason(genericTitle: LocalizedStringKey) -> LoadFailureView.Reason {
        switch self {
        case .offline: .offline
        case .generic: .generic(title: genericTitle)
        case .missingAPIKey: .custom(
            title: "TMDB API key missing",
            message: "Add your key to Config/Secrets.xcconfig and rebuild.",
            systemImage: "key"
        )
        }
    }
}
