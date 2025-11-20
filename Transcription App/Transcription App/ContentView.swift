import SwiftUI
import SwiftData
import WhisperKit
import Combine
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recordingObjects: [Recording]
    @StateObject private var player = MiniPlayer()
    
    @State private var searchText: String = ""
    @State private var filteredRecordings: [Recording] = []

    
    @State private var selectedRecording: Recording? = nil
    
    private func updateFilteredRecordings() {
        if searchText.isEmpty {
            filteredRecordings = recordingObjects
        } else {
            filteredRecordings = recordingObjects.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.fullText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }



    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 20) {
                RecorderView(onFinishRecording: { url in
                    Task {
                        await addRecordingAndTranscribe(fileURL: url)
                    }
                })

                Text("My Recordings")
                    .font(.title)
                    .padding(.top)

                Button("Add Recording") {
                    Task {
                        await addRecordingAndTranscribe()
                    }
                }
                .buttonStyle(.borderedProminent)

                List(selection: $selectedRecording) {
                    ForEach(filteredRecordings) { recording in
                        HStack {
                            Text(recording.title)
                                .lineLimit(1)

                            Spacer()

                            Button {
                                if player.playingURL == recording.fileURL && player.isPlaying {
                                    player.pause()
                                } else {
                                    player.play(recording.fileURL)
                                }
                            } label: {
                                Image(systemName: (player.playingURL == recording.fileURL && player.isPlaying) ? "pause.fill" : "play.fill")
                            }
                            .buttonStyle(.plain)

                            ProgressView(value: player.playingURL == recording.fileURL ? player.progress : 0)
                                .frame(width: 60)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecording = recording
                        }
                    }
                    .onDelete(perform: deleteRecordings)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            .padding()
            .searchable(text: $searchText, prompt: "Search recordings") // <- attach here
            .onChange(of: searchText) { _ in updateFilteredRecordings() }
            .onChange(of: recordingObjects) { _ in updateFilteredRecordings() }

        } detail: {
            if let selected = selectedRecording {
                ScrollView {
                    Text(selected.fullText)
                        .padding()
                }
            } else {
                Text("Select a recording")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }

    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recordingObjects[index])
            }
        }
    }

    private func addRecordingAndTranscribe(fileURL: URL? = nil, filePath: String? = nil) async {
        let audioURL: URL
        if let fileURL {
            audioURL = fileURL
        } else if let filePath {
            audioURL = URL(fileURLWithPath: filePath)
        } else {
            guard let sampleURL = Bundle.main.url(forResource: "jfk", withExtension: "wav") else {
                print("Audio file not found!")
                return
            }
            audioURL = sampleURL
        }

        do {
            let pipe = try await WhisperKit(WhisperKitConfig(model: "tiny"))
            let results = try await pipe.transcribe(audioPath: audioURL.path)

            guard let firstResult = results.first else { return }

            let segments = firstResult.segments.map { seg in
                RecordingSegment(
                    start: Double(seg.start),
                    end: Double(seg.end),
                    text: seg.text
                )
            }

            let recording = Recording(
                title: audioURL.lastPathComponent,
                fileURL: audioURL,
                filePath: audioURL.path,
                fullText: firstResult.text,
                language: firstResult.language,
                segments: segments,
                recordedAt: Date()
            )

            modelContext.insert(recording)

        } catch {
            print("Transcription faile2d:", error)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recording.self, RecordingSegment.self], inMemory: true)
}
