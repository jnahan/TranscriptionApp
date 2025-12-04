import Foundation
import SwiftData

/// Represents a single audio recording with its transcription
/// Contains the audio file, full transcribed text, segments with timestamps,
/// optional notes, and optional folder organization
@Model
class Recording {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID
    
    // MARK: - Basic Info
    var title: String
    var recordedAt: Date
    var language: String
    
    // MARK: - Audio File
    var filePath: String
    
    // MARK: - Transcription
    var fullText: String // Complete transcription
    @Relationship(deleteRule: .cascade)
    var segments: [RecordingSegment] = [] // Timestamped segments
    
    // MARK: - User Notes
    var notes: String
    
    // MARK: - Organization
    @Relationship(inverse: \Collection.recordings)
    var collection: Collection?
    
    // MARK: - Computed Properties
    var resolvedURL: URL? {
        return URL(fileURLWithPath: filePath)
    }
    
    init(
        title: String,
        fileURL: URL,  // Only accept URL, no need for filePath parameter
        fullText: String,
        language: String,
        notes: String = "",
        segments: [RecordingSegment] = [],
        collection: Collection? = nil,
        recordedAt: Date
    ) {
        self.id = UUID()
        self.title = title
        self.filePath = fileURL.path  // Convert URL to path string
        self.fullText = fullText
        self.language = language
        self.notes = notes
        self.segments = segments
        self.collection = collection
        self.recordedAt = recordedAt
    }
}
