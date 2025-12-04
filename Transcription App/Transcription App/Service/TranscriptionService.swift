import Foundation
import WhisperKit

/// Service for handling audio transcription using WhisperKit
class TranscriptionService {
    // MARK: - Singleton
    static let shared = TranscriptionService()
    
    // MARK: - Properties
    private var whisperKit: WhisperKit?
    private let modelName = "tiny"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    // MARK: - Private Helpers
    
    /// Cleans WhisperKit timestamp tokens from text (e.g., <|9.84|>, <|en|>, <|transcribe|>)
    private func cleanTimestampTokens(from text: String) -> String {
        // Remove all tokens matching pattern <|...|>
        let pattern = "<\\|[^|]+\\|>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        
        let range = NSRange(text.startIndex..., in: text)
        var cleanedText = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
        
        // Remove leading dashes and whitespace that might be left after token removal
        cleanedText = cleanedText.trimmingCharacters(in: .whitespaces)
        if cleanedText.hasPrefix("-") {
            cleanedText = String(cleanedText.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        
        return cleanedText
    }
    
    /// Transcribes an audio file and returns the result
    /// - Parameter audioURL: URL of the audio file to transcribe
    /// - Returns: TranscriptionResult with text, language, and segments
    /// - Throws: TranscriptionError if transcription fails
    func transcribe(audioURL: URL) async throws -> TranscriptionResult {
        // Ensure WhisperKit is initialized
        if whisperKit == nil {
            whisperKit = try await WhisperKit(WhisperKitConfig(model: modelName))
        }
        
        guard let whisperKit = whisperKit else {
            throw TranscriptionError.initializationFailed
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.fileNotFound
        }
        
        // Perform transcription with word-level timestamps for better segmentation
        let options = DecodingOptions(
            wordTimestamps: true
        )
        let results = try await whisperKit.transcribe(audioPath: audioURL.path, decodeOptions: options)
        
        guard let firstResult = results.first else {
            throw TranscriptionError.noResults
        }
        
        // Convert to our model and clean timestamp tokens
        let segments = firstResult.segments.map { segment in
            TranscriptionSegment(
                start: Double(segment.start),
                end: Double(segment.end),
                text: cleanTimestampTokens(from: segment.text)
            )
        }
        
        return TranscriptionResult(
            text: cleanTimestampTokens(from: firstResult.text),
            language: firstResult.language,
            segments: segments
        )
    }
}

// MARK: - Models

/// Result of a transcription operation
struct TranscriptionResult {
    let text: String
    let language: String
    let segments: [TranscriptionSegment]
}

/// A time-stamped segment of transcription
struct TranscriptionSegment {
    let start: Double
    let end: Double
    let text: String
}

// MARK: - Errors

enum TranscriptionError: LocalizedError {
    case initializationFailed
    case fileNotFound
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .initializationFailed:
            return "Failed to initialize transcription engine"
        case .fileNotFound:
            return "Audio file not found"
        case .noResults:
            return "No transcription results returned"
        }
    }
}
