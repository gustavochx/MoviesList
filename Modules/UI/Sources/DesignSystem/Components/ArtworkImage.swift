import SwiftUI

/// A remote image at a fixed size, clipped to a rounded rectangle.
public struct ArtworkImage: View {
    let url: URL?
    let size: CGSize
    let cornerRadius: CGFloat
    let fallbackSymbol: String

    public init(url: URL?, size: CGSize, cornerRadius: CGFloat, fallbackSymbol: String = "photo") {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        self.fallbackSymbol = fallbackSymbol
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension ArtworkImage {
    var content: some View {
        RemoteImage(url: url, fallbackSymbol: fallbackSymbol)
            .frame(width: size.width, height: size.height)
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}

#if DEBUG
#Preview {
    ArtworkImage(url: nil, size: CGSize(width: 100, height: 150), cornerRadius: DSRadius.medium, fallbackSymbol: "film")
}
#endif
