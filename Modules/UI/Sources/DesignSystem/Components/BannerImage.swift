import SwiftUI

/// A full-width remote image at a fixed height, cropped to fill.
public struct BannerImage: View {
    let url: URL?
    let height: CGFloat
    let fallbackSymbol: String

    public init(url: URL?, height: CGFloat, fallbackSymbol: String = "photo") {
        self.url = url
        self.height = height
        self.fallbackSymbol = fallbackSymbol
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension BannerImage {
    var content: some View {
        // A fixed-height clear frame keeps the filled image from widening the layout.
        Color.clear
            .frame(height: height)
            .overlay { RemoteImage(url: url, fallbackSymbol: fallbackSymbol) }
            .clipped()
    }
}

#if DEBUG
#Preview {
    BannerImage(url: nil, height: 220)
}
#endif
