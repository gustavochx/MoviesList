import DesignSystem
import SwiftUI

/// The wide backdrop image at the top of the detail screen. Decorative, so hidden from VoiceOver.
struct MovieDetailBackdrop: View {
    let url: URL?

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension MovieDetailBackdrop {
    var content: some View {
        BannerImage(url: url, height: 220)
            .accessibilityHidden(true)
    }
}
