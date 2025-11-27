import SwiftUI
import SwiftData
import Foundation

struct TranscriptionDetailView: View {
    @Binding var isPresented: Bool
    let audioURL: URL
    let onSave: (String, String, String) -> Void
    
    @State private var title: String = ""
    @State private var folder: String = ""
    @State private var note: String = ""
    @State private var isTranscribing = false
    
    var body: some View {
        NavigationView {
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
                            
                            Text("transcribing audio / transcribing audio")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 32)
                    }
                    .padding(.top, 60)
                }
                
                VStack(spacing: 16) {
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
                        TextField("Folder", text: $folder)
                            .textFieldStyle(.plain)
                            .font(.title3)
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
                
                Spacer()
                
                Button {
                    onSave(title, folder, note)
                    isPresented = false
                } label: {
                    Text("Save transcription")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .cornerRadius(30)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            title = audioURL.deletingPathExtension().lastPathComponent
            // Start transcription
            isTranscribing = true
            // Simulate transcription (replace with actual transcription)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isTranscribing = false
            }
        }
    }
}
