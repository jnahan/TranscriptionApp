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
        guard let appSupportDir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        // Try to resolve as relative path first (new recordings)
        let relativeURL = appSupportDir.appendingPathComponent(filePath)
        if FileManager.default.fileExists(atPath: relativeURL.path) {
            return relativeURL
        }
        
        // Fallback: Handle old absolute paths by extracting filename and looking in Recordings folder
        let filename = URL(fileURLWithPath: filePath).lastPathComponent
        let fallbackURL = appSupportDir
            .appendingPathComponent("Recordings")
            .appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fallbackURL.path) {
            return fallbackURL
        }
        
        // Last resort: try the original absolute path (will fail for old recordings after rebuild)
        let absoluteURL = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: absoluteURL.path) {
            return absoluteURL
        }
        
        return nil
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
        
        // Store relative path from Application Support directory
        if let appSupportDir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
           fileURL.path.hasPrefix(appSupportDir.path) {
            // Extract relative path
            self.filePath = String(fileURL.path.dropFirst(appSupportDir.path.count + 1))
        } else {
            // Fallback to absolute path if we can't determine relative path
            self.filePath = fileURL.path
        }
        
        self.fullText = fullText
        self.language = language
        self.notes = notes
        self.segments = segments
        self.collection = collection
        self.recordedAt = recordedAt
    }
}
