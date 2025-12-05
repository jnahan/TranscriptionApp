import Foundation
import LLM

/// Service for handling LLM interactions using Qwen3 model
class LLMService {
    // MARK: - Singleton
    static let shared = LLMService()
    
    // MARK: - Properties
    private var llm: LLM?
    private var isLoadingModel = false
    
    // MARK: - Initialization
    private init() {
        // Preload the model in the background
        Task {
            await preloadModel()
        }
    }
    
    // MARK: - Public Methods
    
    /// Preloads the Qwen3 model to reduce latency
    func preloadModel() async {
        guard !isLoadingModel else { return }
        guard llm == nil else { return }
        
        isLoadingModel = true
        defer { isLoadingModel = false }
        
        guard let modelURL = Bundle.main.url(forResource: "Qwen3-0.6B-Q4_K_M", withExtension: "gguf") else {
            print("LLMService: Could not find Qwen3 model in bundle")
            return
        }
        
        // Qwen3 uses ChatML template
        let systemPrompt = "You are a helpful AI assistant."
        llm = LLM(from: modelURL, template: .chatML(systemPrompt))
    }
    
    /// Gets a completion from the LLM
    /// - Parameters:
    ///   - input: The user's input text
    ///   - systemPrompt: Optional custom system prompt. If nil, uses default.
    /// - Returns: The LLM's response
    /// - Throws: LLMError if the request fails
    func getCompletion(from input: String, systemPrompt: String? = nil) async throws -> String {
        // Ensure model is loaded
        if llm == nil {
            await preloadModel()
        }
        
        guard let llm = llm else {
            throw LLMError.modelNotLoaded
        }
        
        // Update system prompt if provided
        if let systemPrompt = systemPrompt {
            llm.template = .chatML(systemPrompt)
        }
        
        let question = llm.preprocess(input, llm.history)
        let answer = await llm.getCompletion(from: question)
        return cleanOutput(answer)
    }
    
    /// Responds to input and updates history automatically
    /// - Parameters:
    ///   - input: The user's input text
    ///   - systemPrompt: Optional custom system prompt. If nil, uses default.
    ///   - onUpdate: Optional closure called with incremental updates as the response is generated
    /// - Returns: The complete LLM's response
    /// - Throws: LLMError if the request fails
    func respond(to input: String, systemPrompt: String? = nil, onUpdate: ((String?) -> Void)? = nil) async throws -> String {
        // Ensure model is loaded
        if llm == nil {
            await preloadModel()
        }
        
        guard let llm = llm else {
            throw LLMError.modelNotLoaded
        }
        
        // Update system prompt if provided
        if let systemPrompt = systemPrompt {
            llm.template = .chatML(systemPrompt)
        }
        
        // Set up update handler if provided
        if let onUpdate = onUpdate {
            llm.update = onUpdate
        }
        
        await llm.respond(to: input)
        return cleanOutput(llm.output)
    }
    
    /// Cleans the LLM output by removing thinking tokens and reasoning patterns
    private func cleanOutput(_ output: String) -> String {
        var cleaned = output
        
        // Remove common thinking patterns
        let thinkingPatterns = [
            // Thinking tags (including backtick-wrapped ones)
            "`<think>.*?</think>`",
            "<think>.*?</think>",
            "<thinking>.*?</thinking>",
            "\\[think\\].*?\\[/think\\]",
            "\\[thinking\\].*?\\[/thinking\\]",
            
            // Thinking phrases at the start
            "^\\s*(Let me think|Let me consider|Let me analyze|Thinking|Hmm|Well, let me|I need to think|Let me process).*?\\n",
            "^\\s*(Let me think|Let me consider|Let me analyze|Thinking|Hmm|Well, let me|I need to think|Let me process).*?\\.",
            
            // Reasoning blocks
            "First,.*?\\n",
            "Let me break this down.*?\\n",
            "To answer this.*?\\n",
        ]
        
        for pattern in thinkingPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let range = NSRange(cleaned.startIndex..., in: cleaned)
                cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
            }
        }
        
        // Remove multiple consecutive newlines
        cleaned = cleaned.replacingOccurrences(of: "\n\n\n+", with: "\n\n", options: .regularExpression)
        
        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    /// Clears the conversation history
    func clearHistory() {
        llm?.history = []
    }
    
    /// Gets the current conversation history
    var history: [(role: Role, content: String)] {
        return llm?.history ?? []
    }
    
    /// Checks if the model is loaded and ready
    var isReady: Bool {
        return llm != nil
    }
}

// MARK: - Errors

enum LLMError: LocalizedError {
    case modelNotLoaded
    case initializationFailed
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "LLM model is not loaded. Please wait for initialization."
        case .initializationFailed:
            return "Failed to initialize LLM model"
        }
    }
}

