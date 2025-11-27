import Foundation
import SwiftData

@Model
class RecordingSegment {
    @Attribute(.unique) var id: UUID = UUID()   // Unique identifier
    var start: Double
    var end: Double
    var text: String
    
    // Inverse relationship back to Recording
    @Relationship(inverse: \Recording.segments) var recording: Recording?

    init(start: Double, end: Double, text: String) {
        self.start = start
        self.end = end
        self.text = text
    }
}
