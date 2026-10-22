import SwiftUI

/// A star followed by an already-formatted rating and an optional secondary detail. Callers set the font.
public struct RatingView: View {
    let value: String
    let detail: String?

    public init(value: String, detail: String? = nil) {
        self.value = value
        self.detail = detail
    }

    public var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension RatingView {
    var content: some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: "star.fill")
                .foregroundStyle(DSColor.rating)
                .accessibilityHidden(true)
            Text(verbatim: value)
            if let detail {
                Text(verbatim: "· \(detail)")
                    .foregroundStyle(DSColor.secondaryText)
            }
        }
        // One VoiceOver element reading the value and detail; callers can replace it with a fuller label.
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: DSSpacing.m) {
        RatingView(value: "8.1")
        RatingView(value: "8.1", detail: "12,345 votes")
    }
    .font(DSFont.meta)
}
#endif
