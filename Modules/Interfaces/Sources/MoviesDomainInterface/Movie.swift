import Foundation

/// The first domain model. Rename it and add the fields your app needs.
public struct Movie: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let createdAt: Date

    public init(id: UUID = UUID(), createdAt: Date) {
        self.id = id
        self.createdAt = createdAt
    }
}
