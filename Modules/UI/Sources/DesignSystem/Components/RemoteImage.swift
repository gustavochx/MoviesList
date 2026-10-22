import SwiftUI

/// An `AsyncImage` that fills its frame, with a spinner while loading and `fallbackSymbol` when there's no image.
/// Callers set the frame and clip shape.
public struct RemoteImage: View {
    let url: URL?
    let fallbackSymbol: String

    public init(url: URL?, fallbackSymbol: String = "photo") {
        self.url = url
        self.fallbackSymbol = fallbackSymbol
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension RemoteImage {
    var content: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty where url != nil:
                placeholder { ProgressView() }
            default:
                placeholder {
                    Image(systemName: fallbackSymbol)
                        .foregroundStyle(DSColor.secondaryText)
                }
            }
        }
    }

    func placeholder(@ViewBuilder _ content: () -> some View) -> some View {
        Rectangle()
            .fill(DSColor.placeholder)
            .overlay(content())
    }
}

#if DEBUG
#Preview {
    HStack(spacing: DSSpacing.l) {
        RemoteImage(url: nil)
            .frame(width: 100, height: 150)
        RemoteImage(url: nil, fallbackSymbol: "person.fill")
            .frame(width: 72, height: 72)
            .clipShape(.circle)
    }
}
#endif
