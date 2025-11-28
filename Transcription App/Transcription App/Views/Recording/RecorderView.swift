import SwiftUI
import SwiftData

struct RecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showTranscriptionDetail = false
    @State private var pendingAudioURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background - OUTSIDE safe area
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.93), // Top: light peach/beige
                        Color(red: 1.0, green: 0.85, blue: 0.88)   // Bottom: light pink
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Content - INSIDE safe area
                VStack(spacing: 0) {
                    CustomTopBar(
                        title: "Recording",
                        leftIcon: "x",
                        onLeftTap: { dismiss() }
                    )
                    
                    RecorderControl(onFinishRecording: { url in
                        print("=== RecorderControl finished with URL: \(url)")
                        pendingAudioURL = url
                        showTranscriptionDetail = true
                    })
                }
                // VStack does NOT ignore safe area, so it stays within bounds
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: Binding(
                get: { showTranscriptionDetail ? pendingAudioURL : nil },
                set: { newValue in
                    if newValue == nil {
                        showTranscriptionDetail = false
                        pendingAudioURL = nil
                    }
                }
            )) { audioURL in
                CreateRecordingView(
                    isPresented: $showTranscriptionDetail,
                    audioURL: audioURL,
                    folders: folders,
                    modelContext: modelContext,
                    onTranscriptionComplete: {
                        pendingAudioURL = nil
                        showTranscriptionDetail = false
                        dismiss()
                    }
                )
            }
        }
    }
}
