import Foundation
import AVFoundation

/// Utility for audio file operations
class AudioHelper {
    
    /// Load the duration of an audio file
    /// - Parameter url: URL of the audio file
    /// - Returns: Duration in seconds
    /// - Throws: Error if duration cannot be loaded
    static func loadDuration(from url: URL) async throws -> TimeInterval {
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        return duration.seconds
    }
}
