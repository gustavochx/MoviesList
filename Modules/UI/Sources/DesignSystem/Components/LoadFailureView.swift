import SwiftUI

/// Full-screen load failure with a retry button. The reason picks the icon and texts.
public struct LoadFailureView: View {
    /// Why the load failed, reduced to what the user can act on.
    public enum Reason: Equatable {
        /// No connection.
        case offline
        /// Anything else; `title` names what failed to load.
        case generic(title: LocalizedStringKey)
        /// Caller-provided texts and symbol, for failures specific to the app.
        case custom(title: LocalizedStringKey, message: LocalizedStringKey, systemImage: String)

        var systemImage: String {
            switch self {
            case .offline: "wifi.slash"
            case .generic: "exclamationmark.triangle"
            case let .custom(_, _, systemImage): systemImage
            }
        }
    }

    let reason: Reason
    let retry: () -> Void

    public init(reason: Reason, retry: @escaping () -> Void) {
        self.reason = reason
        self.retry = retry
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension LoadFailureView {
    var content: some View {
        ErrorStateView(title: title, message: message, systemImage: reason.systemImage, retry: retry)
    }

    var title: LocalizedStringKey {
        switch reason {
        case .offline: "You're offline"
        case let .generic(title): title
        case let .custom(title, _, _): title
        }
    }

    var message: LocalizedStringKey {
        switch reason {
        case .offline: "Check your connection and try again."
        case .generic: "Something went wrong. Please try again."
        case let .custom(_, message, _): message
        }
    }
}

#if DEBUG
#Preview("Offline") {
    LoadFailureView(reason: .offline, retry: {})
}

#Preview("Generic") {
    LoadFailureView(reason: .generic(title: "Couldn't load this"), retry: {})
}

#Preview("Custom") {
    LoadFailureView(
        reason: .custom(title: "Key missing", message: "Add your key and rebuild.", systemImage: "key"),
        retry: {}
    )
}
#endif
