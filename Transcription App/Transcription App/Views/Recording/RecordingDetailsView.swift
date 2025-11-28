import SwiftUI
import SwiftData
import AVFoundation

struct RecordingDetailsView: View {
    let recording: Recording
    @StateObject private var audioPlayer = AudioPlayerController()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showShareSheet = false
    @State private var showNotePopup = false  // Keep this for the overlay
    @State private var showEditTitle = false
    @State private var newTitle = ""
    @State private var showDeleteConfirm = false
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            Color.warmGray50
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Top Bar
                HStack(spacing: 0) {
                    Button {
                        dismiss()
                    } label: {
                        Image("caret-left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.warmGray400)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    // Clover icon in center
                    Image("clover")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .foregroundColor(.accent)
                    
                    Spacer()
                    
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                            .foregroundColor(.warmGray400)
                            .rotationEffect(.degrees(90))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(height: 68)
                .background(Color.warmGray50)
                
                // Header with date and title
                VStack(spacing: 8) {
                    Text(relativeDate)
                        .font(.system(size: 16))
                        .foregroundColor(.warmGray500)
                    
                    Text(recording.title)
                        .font(.custom("LibreBaskerville-Regular", size: 24))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Scrollable Transcript Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !recording.segments.isEmpty {
                            ForEach(recording.segments) { segment in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(formatTime(segment.start))
                                        .font(.system(size: 14))
                                        .foregroundColor(.warmGray500)
                                    
                                    Text(segment.text)
                                        .font(.system(size: 17))
                                        .foregroundColor(.baseBlack)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        } else {
                            Text(recording.fullText)
                                .font(.system(size: 17))
                                .foregroundColor(.baseBlack)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .padding(.bottom, 200)
                }
                
                Spacer()
            }
            
            // Audio Player Controls (Fixed at bottom)
            VStack {
                Spacer()
                
                AudioPlayerControls(
                    audioPlayer: audioPlayer,
                    audioURL: recording.resolvedURL,
                    fullText: recording.fullText,
                    onNotePressed: {
                        showNotePopup = true
                    },
                    onSharePressed: {
                        showShareSheet = true
                    }
                )
            }
            
            // Note Overlay
            if showNotePopup {
                NoteOverlay(
                    isPresented: $showNotePopup,
                    noteText: recording.notes
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showNotePopup)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .confirmationDialog("", isPresented: $showMenu, titleVisibility: .hidden) {
            Button("Export Audio") {
                if let url = recording.resolvedURL {
                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.keyWindow?.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                }
            }
            
            Button("Edit") {
                showEditTitle = true
                newTitle = recording.title
            }
            
            Button("Delete", role: .destructive) {
                showDeleteConfirm = true
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = recording.resolvedURL {
                ShareSheet(items: [recording.fullText, url])
            } else {
                ShareSheet(items: [recording.fullText])
            }
        }
        .alert("Edit Title", isPresented: $showEditTitle) {
            TextField("Title", text: $newTitle)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                recording.title = newTitle
            }
        }
        .alert("Delete Recording?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(recording)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            if let url = recording.resolvedURL {
                audioPlayer.loadAudio(url: url)
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    private var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(recording.recordedAt) {
            return "Today"
        } else if calendar.isDateInYesterday(recording.recordedAt) {
            return "Yesterday"
        } else {
            let components = calendar.dateComponents([.day], from: recording.recordedAt, to: now)
            if let days = components.day, days < 7 {
                return "\(days)d ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: recording.recordedAt)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


// MARK: - Audio Player Controller
class AudioPlayerController: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    func loadAudio(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
        } catch {
            print("Failed to load audio: \(error)")
        }
    }
    
    func play(url: URL) {
        if player == nil {
            loadAudio(url: url)
        }
        player?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    func skip(by seconds: TimeInterval) {
        let newTime = max(0, min(duration, currentTime + seconds))
        seek(to: newTime)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
            
            if !player.isPlaying && self.isPlaying {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
