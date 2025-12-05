import Foundation
import SwiftUI
import SwiftData

/// ViewModel for RecordingDetailsView handling summary generation
class RecordingDetailsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isGeneratingSummary = false
    @Published var summaryError: String?
    
    // MARK: - Private Properties
    
    private let recording: Recording
    
    // MARK: - Initialization
    
    init(recording: Recording) {
        self.recording = recording
    }
    
    // MARK: - Public Methods
    
    /// Generates a summary for the recording if one doesn't exist
    /// - Parameter modelContext: The SwiftData model context to save changes
    func generateSummaryIfNeeded(modelContext: ModelContext) async {
        // If summary already exists and is not empty, don't regenerate
        if let summary = recording.summary, !summary.isEmpty {
            return
        }
        
        await generateSummary(modelContext: modelContext)
    }
    
    /// Explicitly generates or regenerates a summary for the recording
    /// - Parameter modelContext: The SwiftData model context to save changes
    func generateSummary(modelContext: ModelContext) async {
        // If transcription is empty, can't generate summary
        guard !recording.fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                summaryError = "Cannot generate summary: transcription is empty"
            }
            return
        }
        
        await MainActor.run {
            isGeneratingSummary = true
            summaryError = nil
        }
        
        // Ensure LLM model is loaded
        if !LLMService.shared.isReady {
            await LLMService.shared.preloadModel()
        }
        
        // Check again after preloading
        guard LLMService.shared.isReady else {
            await MainActor.run {
                isGeneratingSummary = false
                summaryError = "LLM model is not ready. Please try again in a moment."
            }
            return
        }
        
        do {
            // Clear history before generating a new summary to avoid context position errors
            LLMService.shared.clearHistory()
            
            let systemPrompt = "You are a helpful assistant. Provide direct, concise responses without showing your thinking process or reasoning steps."
            let prompt = "Please generate a concise summary for this transcription. Provide only the summary, without any thinking or reasoning:\n\n\(recording.fullText)"
            
            let summary = try await LLMService.shared.getCompletion(from: prompt, systemPrompt: systemPrompt)
            
            await MainActor.run {
                recording.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
                isGeneratingSummary = false
                
                // Save the changes
                try? modelContext.save()
            }
        } catch {
            await MainActor.run {
                isGeneratingSummary = false
                summaryError = "Failed to generate summary: \(error.localizedDescription)"
            }
        }
    }
}

