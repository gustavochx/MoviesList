import SwiftUI

/// Full-screen error with a retry button.
public struct ErrorStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let systemImage: String
    let retryTitle: LocalizedStringKey
    let retry: () -> Void

    public init(
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        systemImage: String,
        retryTitle: LocalizedStringKey = "Try Again",
        retry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.retryTitle = retryTitle
        self.retry = retry
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension ErrorStateView {
    var content: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button(retryTitle, action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG
#Preview {
    ErrorStateView(
        title: "You're offline",
        message: "Check your connection and try again.",
        systemImage: "wifi.slash",
        retry: {}
    )
}
#endif
