import SwiftData
import Foundation
import WhisperKit

@Model
class Recording {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var notes: String = ""
    
    // Either fileURL or filePath can be set
    var fileURL: URL?
    var filePath: String?
    
    var language: String
    var fullText: String
    
    // One-to-many relationship with RecordingSegment
    @Relationship var segments: [RecordingSegment] = []
    @Relationship(inverse: \Folder.recordings) var folder: Folder?  // Optional folder

    var recordedAt: Date
    var savedAt: Date = Date()

    init(title: String,
            fileURL: URL? = nil,
            filePath: String? = nil,
            fullText: String,
            language: String,
            notes: String = "",
            segments: [RecordingSegment] = [],
            folder: Folder? = nil,
            recordedAt: Date) {
           self.title = title
           self.fileURL = fileURL
           self.filePath = filePath
           self.fullText = fullText
           self.language = language
           self.notes = notes
           self.segments = segments
           self.folder = folder
           self.recordedAt = recordedAt
       }
    
    // Convenience computed property to get a URL regardless of source
    var resolvedURL: URL? {
        if let fileURL { return fileURL }
        if let filePath { return URL(fileURLWithPath: filePath) }
        return nil
    }
}
