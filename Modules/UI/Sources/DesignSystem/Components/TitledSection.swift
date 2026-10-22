import SwiftUI

/// A titled section: a header-trait title above any content.
public struct TitledSection<Content: View>: View {
    let title: LocalizedStringKey
    /// The caller's views shown under the title.
    let sectionContent: Content

    public init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.sectionContent = content()
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension TitledSection {
    var content: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text(title)
                .font(DSFont.sectionTitle)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            sectionContent
        }
    }
}

#if DEBUG
#Preview {
    TitledSection("Overview") {
        Text("A short description.")
            .padding(.horizontal)
    }
}
#endif
