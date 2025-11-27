import SwiftUI

/// Reusable row component for displaying a recording with playback controls and menu actions
struct RecordingRow: View {
    // MARK: - Properties
    let recording: Recording
    @ObservedObject var player: MiniPlayer
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack {
            // Recording Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.title)
                    .lineLimit(1)
                
                Text(recording.recordedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Play/Pause Button
            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.plain)
            
            // Progress Bar
            ProgressView(value: isPlaying ? player.progress : 0)
                .frame(width: 60)
            
            // Actions Menu
            Menu {
                Button(action: onCopy) {
                    Label("Copy Transcription", systemImage: "doc.on.doc")
                }
                
                Button {
                    shareTranscription()
                } label: {
                    Label("Share Transcription", systemImage: "square.and.arrow.up")
                }
                
                Button {
                    exportAudio()
                } label: {
                    Label("Export Audio", systemImage: "square.and.arrow.up.fill")
                }
                
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
        }
    }
    
    // MARK: - Computed Properties
    private var isPlaying: Bool {
        player.playingURL == recording.resolvedURL && player.isPlaying
    }
    
    // MARK: - Actions
    private func togglePlayback() {
        if isPlaying {
            player.pause()
        } else if let url = recording.resolvedURL {
            player.play(url)
        }
    }
    
    private func shareTranscription() {
        let activityVC = UIActivityViewController(
            activityItems: [recording.fullText],
            applicationActivities: nil
        )
        presentActivityViewController(activityVC)
    }
    
    private func exportAudio() {
        guard let url = recording.resolvedURL else { return }
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        presentActivityViewController(activityVC)
    }
    
    private func presentActivityViewController(_ activityVC: UIActivityViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.keyWindow?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
