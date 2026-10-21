import SwiftUI

/// An `AsyncImage` that fills its frame, with a spinner while loading and `fallbackSymbol` when there's no image.
/// Callers set the frame and clip shape.
struct RemoteImage: View {
    let url: URL?
    var fallbackSymbol = "film"

    var body: some View {
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
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func placeholder(@ViewBuilder _ content: () -> some View) -> some View {
        Rectangle()
            .fill(.quaternary)
            .overlay(content())
    }
}
