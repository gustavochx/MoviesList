import SwiftUI

/// Full-screen centered spinner for a loading state.
public struct LoadingStateView: View {
    public init() {}

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension LoadingStateView {
    var content: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    LoadingStateView()
}
#endif
