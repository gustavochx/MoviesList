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
        // A fixed-height clear frame keeps the filled image from widening the layout.
        Color.clear
            .frame(height: 220)
            .overlay { RemoteImage(url: url, fallbackSymbol: "photo") }
            .clipped()
            .accessibilityHidden(true)
    }
}
