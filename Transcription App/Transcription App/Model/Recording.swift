import SwiftData
import Foundation
import WhisperKit

@Model
class Recording {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var fileURL: URL
    var fullText: String
    var language: String
    
    // One-to-many relationship with RecordingSegment
    @Relationship var segments: [RecordingSegment] = []

    var recordedAt: Date
    var savedAt: Date = Date()

    init(title: String,
         fileURL: URL,
         fullText: String,
         language: String,
         segments: [RecordingSegment] = [],
         recordedAt: Date) {
        self.title = title
        self.fileURL = fileURL
        self.fullText = fullText
        self.language = language
        self.segments = segments
        self.recordedAt = recordedAt
    }
}

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
