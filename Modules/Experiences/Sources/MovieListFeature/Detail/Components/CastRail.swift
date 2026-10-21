import MoviesDomainInterface
import SwiftUI

/// The horizontally scrolling top-cast row.
struct CastRail: View {
    let cast: [CastMember]

    var body: some View {
        content
    }
}

// MARK: UI Building Blocks
private extension CastRail {
    var content: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 12) {
                ForEach(cast) { member in
                    CastCard(member: member)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

#if DEBUG
#Preview {
    CastRail(cast: (1...8).map { .fixture(id: $0, name: "Actor \($0)", character: "Character \($0)") })
}
#endif
