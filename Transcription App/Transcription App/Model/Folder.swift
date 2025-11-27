import SwiftData
import Foundation

@Model
class Folder {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    
    // One-to-many relationship with recordings
    @Relationship(deleteRule: .cascade) var recordings: [Recording] = []
    
    init(name: String) {
        self.name = name
    }
}
