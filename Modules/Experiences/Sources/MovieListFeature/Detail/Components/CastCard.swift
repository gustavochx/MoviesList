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
        VStack(spacing: 6) {
            RemoteImage(url: member.profileURL, fallbackSymbol: "person.fill")
                .frame(width: 72, height: 72)
                .clipShape(.circle)
            Text(member.name)
                .font(.caption.bold())
                .lineLimit(2)
            if !member.character.isEmpty {
                Text(member.character)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .multilineTextAlignment(.center)
        .frame(width: 88)
        .accessibilityElement(children: .combine)
    }
}
