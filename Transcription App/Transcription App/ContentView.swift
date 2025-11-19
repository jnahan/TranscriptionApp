import SwiftUI
import SwiftData
import WhisperKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recordings: [Recording]

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 20) {
                Text("My Recordings")
                    .font(.title)
                    .padding(.top)

                Button("Add Recording") {
                    Task {
                        await addRecordingAndTranscribe()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            List {
                ForEach(recordings) { recording in
                    NavigationLink {
                        Text(recording.fullText)
                    } label: {
                        Text(recording.title)
                    }
                }
                .onDelete(perform: deleteRecordings)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            Text("Select a recording")
        }
    }

    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recordings[index])
            }
        }
    }

    private func addRecordingAndTranscribe() async {
        guard let fileURL = Bundle.main.url(forResource: "jfk", withExtension: "wav") else {
            print("Audio file not found!")
            return
        }

        do {
            let pipe = try await WhisperKit(WhisperKitConfig(model: "tiny"))
            let results = try await pipe.transcribe(audioPath: fileURL.path)

            guard let firstResult = results.first else { return }

            let segments = firstResult.segments.map { seg in
                RecordingSegment(
                    start: Double(seg.start),
                    end: Double(seg.end),
                    text: seg.text
                )
            }

            let recording = Recording(
                title: "JFK Example",
                fileURL: fileURL,
                fullText: firstResult.text,
                language: firstResult.language,
                segments: segments,
                recordedAt: Date()
            )

            modelContext.insert(recording)

        } catch {
            print("Transcription failed:", error)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recording.self, RecordingSegment.self], inMemory: true)
}
