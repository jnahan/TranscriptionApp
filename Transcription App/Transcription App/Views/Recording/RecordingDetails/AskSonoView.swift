import SwiftUI
import SwiftData

struct AskSonoView: View {
    let recording: Recording
    @StateObject private var viewModel: AskSonoViewModel
    @Environment(\.modelContext) private var modelContext
    
    init(recording: Recording) {
        self.recording = recording
        _viewModel = StateObject(wrappedValue: AskSonoViewModel(recording: recording))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Heading
                Text("How can I help you")
                    .font(.libreMedium(size: 24))
                    .foregroundColor(.baseBlack)
                    .padding(.top, 24)
                
                // Input Field
                VStack(alignment: .leading, spacing: 12) {
                    InputField(
                        text: $viewModel.userPrompt,
                        placeholder: "Ask me anything",
                        isMultiline: true,
                        height: 120
                    )
                    
                    // Send Button
                    Button(action: {
                        Task {
                            await viewModel.sendPrompt()
                        }
                    }) {
                        HStack {
                            if viewModel.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isProcessing ? "Processing..." : "Send")
                                .font(.interSemiBold(size: 16))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.userPrompt.isEmpty || viewModel.isProcessing ? Color.warmGray400 : Color.accent)
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.userPrompt.isEmpty || viewModel.isProcessing)
                }
                
                // Response Area
                if viewModel.isProcessing {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else if let response = viewModel.response, !response.isEmpty {
                    responseView(response: response)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppConstants.UI.Spacing.large)
            .padding(.bottom, 180)
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Thinking...")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.warmGray500)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
    
    private func errorView(error: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Error")
                .font(.interSemiBold(size: 16))
                .foregroundColor(.red)
            
            Text(error)
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.warmGray500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.warmGray100)
        .cornerRadius(12)
        .padding(.top, 8)
    }
    
    private func responseView(response: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Response")
                .font(.interSemiBold(size: 16))
                .foregroundColor(.baseBlack)
            
            Text(response)
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.baseBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.top, 8)
    }
}

// MARK: - View Model

@MainActor
class AskSonoViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var userPrompt: String = ""
    @Published var response: String?
    @Published var isProcessing: Bool = false
    @Published var error: String?
    
    // MARK: - Private Properties
    
    private let recording: Recording
    
    // MARK: - Initialization
    
    init(recording: Recording) {
        self.recording = recording
    }
    
    // MARK: - Public Methods
    
    /// Sends the user's prompt to the LLM with transcription context
    func sendPrompt() async {
        guard !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        guard !recording.fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "Cannot answer questions: transcription is empty."
            return
        }
        
        isProcessing = true
        error = nil
        response = nil
        
        do {
            // Truncate long transcriptions to fit context window
            let maxInputLength = 3000
            let transcriptionText: String
            
            if recording.fullText.count > maxInputLength {
                let beginningLength = Int(Double(maxInputLength) * 0.6)
                let endLength = maxInputLength - beginningLength - 50
                let beginning = String(recording.fullText.prefix(beginningLength))
                let end = String(recording.fullText.suffix(endLength))
                transcriptionText = "\(beginning)\n\n[...]\n\n\(end)"
            } else {
                transcriptionText = recording.fullText
            }
            
            let systemPrompt = "You are a helpful assistant that answers questions about transcriptions. Answer questions directly and concisely based on the provided transcription."
            
            let prompt = """
            Transcription:
            \(transcriptionText)
            
            Question: \(userPrompt)
            """
            
            let llmResponse = try await LLMService.shared.getCompletion(
                from: prompt,
                systemPrompt: systemPrompt
            )
            
            // Validate response
            let trimmedResponse = llmResponse.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedResponse.isEmpty, trimmedResponse.count >= 10 else {
                error = "Model returned invalid response. Please try again."
                isProcessing = false
                return
            }
            
            response = trimmedResponse
            
        } catch {
            self.error = "Failed to get response: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
}
