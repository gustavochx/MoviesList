import SwiftUI

/// Full-screen empty state with an optional action button.
public struct EmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let systemImage: String
    let actionTitle: LocalizedStringKey
    let action: (() -> Void)?

    public init(
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        systemImage: String,
        actionTitle: LocalizedStringKey = "Try Again",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension EmptyStateView {
    var content: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let action {
                Button(actionTitle, action: action)
            }
        }
    }
}

#if DEBUG
#Preview {
    EmptyStateView(title: "Nothing here", message: "Items will show up here.", systemImage: "tray") {}
}

#Preview("No action") {
    EmptyStateView(title: "Nothing here", message: "Items will show up here.", systemImage: "tray")
}
#endif
