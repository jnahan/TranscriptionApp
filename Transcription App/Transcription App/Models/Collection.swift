import SwiftData
import Foundation

/// Represents a collection for organizing recordings
/// Users can create collections and assign recordings to them for better organization
@Model
class Collection {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID
    
    // MARK: - Basic Info
    var name: String
    var createdAt: Date
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade)
    var recordings: [Recording] = []    // All recordings in this collection
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
