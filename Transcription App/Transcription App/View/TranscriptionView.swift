import SwiftUI
import SwiftData
import Foundation
import WhisperKit

struct TranscriptionDetailView: View {
    @Binding var isPresented: Bool
    let audioURL: URL
    let folders: [Folder]
    let modelContext: ModelContext
    let onTranscriptionComplete: () -> Void
    
    @State private var title: String = ""
    @State private var folderName: String = ""
    @State private var note: String = ""
    @State private var isTranscribing = false
    @State private var transcriptionError: String? = nil
    @State private var transcribedText: String = ""
    @State private var transcribedLanguage: String = ""
    @State private var transcribedSegments: [RecordingSegment] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if isTranscribing {
                        VStack(spacing: 16) {
                            Text("Transcribing audio")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Please do not close the app until\ntranscription is complete")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                // Waveform animation
                                HStack(spacing: 2) {
                                    ForEach(0..<20) { i in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.pink)
                                            .frame(width: 3, height: CGFloat.random(in: 10...40))
                                    }
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(.pink)
                                
                                Text("transcribing audio")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 32)
                        }
                        .padding(.top, 60)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                if let error = transcriptionError {
                                    VStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.orange)
                                        
                                        Text("Transcription Error")
                                            .font(.headline)
                                        
                                        Text(error)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Title")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    TextField("Title", text: $title)
                                        .textFieldStyle(.plain)
                                        .font(.title3)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Folder")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    TextField("Folder (optional)", text: $folderName)
                                        .textFieldStyle(.plain)
                                        .font(.title3)
                                    
                                    if !folders.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 8) {
                                                ForEach(folders) { folder in
                                                    Button(folder.name) {
                                                        folderName = folder.name
                                                    }
                                                    .buttonStyle(.bordered)
                                                    .tint(folderName == folder.name ? .pink : .gray)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    TextEditor(text: $note)
                                        .frame(height: 200)
                                        .scrollContentBackground(.hidden)
                                        .font(.body)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .padding()
                        }
                        
                        Button {
                            saveRecording()
                        } label: {
                            Text("Save transcription")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(title.isEmpty ? Color.gray : Color.black)
                                .cornerRadius(30)
                        }
                        .disabled(title.isEmpty)
                        .padding()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .disabled(isTranscribing)
                    }
                }
            }
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
                let pipe = try await WhisperKit(WhisperKitConfig(model: "tiny"))
                let results = try await pipe.transcribe(audioPath: audioURL.path)
                
                if let firstResult = results.first {
                    let segments = firstResult.segments.map { seg in
                        RecordingSegment(
                            start: Double(seg.start),
                            end: Double(seg.end),
                            text: seg.text
                        )
                    }
                    
                    await MainActor.run {
                        transcribedText = firstResult.text
                        transcribedLanguage = firstResult.language
                        transcribedSegments = segments
                        isTranscribing = false
                    }
                } else {
                    await MainActor.run {
                        transcriptionError = "No transcription results returned"
                        isTranscribing = false
                    }
                }
            } catch {
                print("Transcription failed:", error)
                await MainActor.run {
                    transcriptionError = error.localizedDescription
                    isTranscribing = false
                }
            }
        }
    }
    
    private func saveRecording() {
        // Find or create folder
        var targetFolder: Folder? = nil
        if !folderName.isEmpty {
            if let existingFolder = folders.first(where: { $0.name == folderName }) {
                targetFolder = existingFolder
            } else {
                let newFolder = Folder(name: folderName)
                modelContext.insert(newFolder)
                targetFolder = newFolder
            }
        }
        
        let recording = Recording(
            title: title,
            fileURL: audioURL,
            filePath: audioURL.path,
            fullText: transcribedText,
            language: transcribedLanguage,
            notes: note,
            segments: transcribedSegments,
            folder: targetFolder,
            recordedAt: Date()
        )
        
        modelContext.insert(recording)
        
        onTranscriptionComplete()
        isPresented = false
    }
}
