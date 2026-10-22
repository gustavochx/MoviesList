import SwiftUI

/// A remote image clipped to a circle.
public struct AvatarImage: View {
    let url: URL?
    let diameter: CGFloat
    let fallbackSymbol: String

    public init(url: URL?, diameter: CGFloat, fallbackSymbol: String = "person.fill") {
        self.url = url
        self.diameter = diameter
        self.fallbackSymbol = fallbackSymbol
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension AvatarImage {
    var content: some View {
        RemoteImage(url: url, fallbackSymbol: fallbackSymbol)
            .frame(width: diameter, height: diameter)
            .clipShape(.circle)
    }
}

#if DEBUG
#Preview {
    AvatarImage(url: nil, diameter: 72)
}
#endif
