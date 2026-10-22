import DesignSystem
import MoviesDomainInterface
import SwiftUI

/// One cast member: photo, name and character, read by VoiceOver as one element.
struct CastCard: View {
    let member: CastMember

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension CastCard {
    var content: some View {
        VStack(spacing: DSSpacing.xs) {
            AvatarImage(url: member.profileURL, diameter: 72)
            Text(member.name)
                .font(DSFont.captionStrong)
                .lineLimit(2)
            if !member.character.isEmpty {
                Text(member.character)
                    .font(DSFont.caption2)
                    .foregroundStyle(DSColor.secondaryText)
                    .lineLimit(2)
            }
        }
        .multilineTextAlignment(.center)
        .frame(width: 88)
        .accessibilityElement(children: .combine)
    }
}
