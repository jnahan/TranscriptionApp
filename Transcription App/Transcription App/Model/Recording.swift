import SwiftData
import Foundation
import WhisperKit

@Model
class Recording {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    
    // Either fileURL or filePath can be set
    var fileURL: URL?
    var filePath: String?
    
    var fullText: String
    var language: String
    
    // One-to-many relationship with RecordingSegment
    @Relationship var segments: [RecordingSegment] = []

    var recordedAt: Date
    var savedAt: Date = Date()

    init(title: String,
         fileURL: URL? = nil,
         filePath: String? = nil,
         fullText: String,
         language: String,
         segments: [RecordingSegment] = [],
         recordedAt: Date) {
        self.title = title
        self.fileURL = fileURL
        self.filePath = filePath
        self.fullText = fullText
        self.language = language
        self.segments = segments
        self.recordedAt = recordedAt
    }
    
    // Convenience computed property to get a URL regardless of source
    var resolvedURL: URL? {
        if let fileURL { return fileURL }
        if let filePath { return URL(fileURLWithPath: filePath) }
        return nil
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
