import SwiftUI
import SwiftData
import Foundation

struct CreateRecordingView: View {
    @Binding var isPresented: Bool
    let audioURL: URL
    let folders: [Folder]
    let modelContext: ModelContext
    let onTranscriptionComplete: () -> Void
    
    @State private var title: String = ""
    @State private var selectedFolder: Folder? = nil
    @State private var note: String = ""
    @State private var transcriptionError: String? = nil
    @State private var transcribedText: String = ""
    @State private var transcribedLanguage: String = ""
    @State private var transcribedSegments: [RecordingSegment] = []
    @State private var showFolderPicker = false
    @State private var isTranscribing = false
    
    var body: some View {
        ZStack {
            Color.warmGray50
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Transcribing audio")
                        .font(.custom("LibreBaskerville-Regular", size: 24))
                        .foregroundColor(.baseBlack)
                    
                    Text("Please do not close the app\nuntil transcription is complete")
                        .font(.system(size: 16))
                        .foregroundColor(.warmGray500)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                .padding(.bottom, 32)
                
                // Waveform animation
                if isTranscribing {
                    HStack(spacing: 4) {
                        ForEach(0..<20) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accent)
                                .frame(width: 3, height: CGFloat.random(in: 20...60))
                        }
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accent)
                            .padding(.leading, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                
                // Form fields
                VStack(spacing: 16) {
                    // Title field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 14))
                            .foregroundColor(.warmGray500)
                        
                        TextField("Title", text: $title)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    // Folder field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder")
                            .font(.system(size: 14))
                            .foregroundColor(.warmGray500)
                        
                        Button {
                            showFolderPicker = true
                        } label: {
                            HStack {
                                Text(selectedFolder?.name ?? "Folder")
                                    .font(.system(size: 17))
                                    .foregroundColor(.baseBlack)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.warmGray400)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Note field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.system(size: 14))
                            .foregroundColor(.warmGray500)
                        
                        ZStack(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("Write a note for yourself...")
                                    .font(.system(size: 17))
                                    .foregroundColor(.warmGray400)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                            }
                            
                            TextEditor(text: $note)
                                .font(.system(size: 17))
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.white)
                                .cornerRadius(12)
                                .frame(height: 200)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Save button
                Button {
                    saveRecording()
                } label: {
                    Text("Save transcription")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(title.isEmpty || isTranscribing ? Color.warmGray400 : Color.black)
                        .cornerRadius(16)
                }
                .disabled(title.isEmpty || isTranscribing)
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
            }
        }
        .sheet(isPresented: $showFolderPicker) {
            FolderPickerView(
                folders: folders,
                selectedFolder: $selectedFolder,
                modelContext: modelContext,
                isPresented: $showFolderPicker
            )
        }
        .onAppear {
            title = audioURL.deletingPathExtension().lastPathComponent
            startTranscription()
        }
    }
    
    private func startTranscription() {
        isTranscribing = true
        transcriptionError = nil
        
        Task {
            do {
                let result = try await TranscriptionService.shared.transcribe(audioURL: audioURL)
                
                await MainActor.run {
                    transcribedText = result.text
                    transcribedLanguage = result.language
                    transcribedSegments = result.segments.map { segment in
                        RecordingSegment(
                            start: segment.start,
                            end: segment.end,
                            text: segment.text
                        )
                    }
                    isTranscribing = false
                }
            } catch {
                await MainActor.run {
                    transcriptionError = error.localizedDescription
                    isTranscribing = false
                }
            }
        }
    }
    
    private func saveRecording() {
        let recording = Recording(
            title: title,
            fileURL: audioURL,
            fullText: transcribedText,
            language: transcribedLanguage,
            notes: note,
            segments: transcribedSegments,
            folder: selectedFolder,
            recordedAt: Date()
        )
        
        modelContext.insert(recording)
        
        onTranscriptionComplete()
        isPresented = false
    }
}
