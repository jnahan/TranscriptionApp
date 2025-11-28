import SwiftUI
import SwiftData
import AVFoundation

struct RecordingDetailsView: View {
    let recording: Recording
    @StateObject private var audioPlayer = AudioPlayerController()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showShareSheet = false
    @State private var showNotePopup = false
    @State private var showEditTitle = false
    @State private var newTitle = ""
    @State private var showDeleteConfirm = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    // Flower icon
                    Image("clover")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.accent)
                        .padding(.top, 16)
                    
                    // Date
                    Text(relativeDate)
                        .font(.system(size: 16))
                        .foregroundColor(.warmGray500)
                    
                    // Title
                    Text(recording.title)
                        .font(.custom("LibreBaskerville-Regular", size: 24))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 32)
                
                // Scrollable Transcript Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if !recording.segments.isEmpty {
                            ForEach(recording.segments) { segment in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(formatTime(segment.start))
                                        .font(.system(size: 14))
                                        .foregroundColor(.warmGray500)
                                    
                                    Text(segment.text)
                                        .font(.system(size: 17))
                                        .foregroundColor(.baseBlack)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.bottom, 24)
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
                
                VStack(spacing: 16) {
                    // Progress Bar
                    VStack(spacing: 8) {
                        Slider(value: $audioPlayer.currentTime, in: 0...max(audioPlayer.duration, 0.1)) { editing in
                            if !editing {
                                audioPlayer.seek(to: audioPlayer.currentTime)
                            }
                        }
                        .tint(.baseBlack)
                        
                        HStack {
                            Text(formatTime(audioPlayer.currentTime))
                                .font(.system(size: 14))
                                .foregroundColor(.warmGray600)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            Text(formatTime(audioPlayer.duration))
                                .font(.system(size: 14))
                                .foregroundColor(.warmGray600)
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                    
                    // Bottom Action Buttons (ONLY ROW)
                    HStack(spacing: 0) {
                        // Note button
                        Button {
                            showNotePopup = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 24))
                                Text("Note")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.warmGray600)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Rewind 15 button
                        Button {
                            audioPlayer.skip(by: -15)
                        } label: {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 24))
                                .foregroundColor(.warmGray600)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Play/Pause (center)
                        Button {
                            if audioPlayer.isPlaying {
                                audioPlayer.pause()
                            } else {
                                if let url = recording.resolvedURL {
                                    audioPlayer.play(url: url)
                                }
                            }
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.baseBlack)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Forward 15 button
                        Button {
                            audioPlayer.skip(by: 15)
                        } label: {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 24))
                                .foregroundColor(.warmGray600)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Copy button
                        Button {
                            UIPasteboard.general.string = recording.fullText
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 24))
                                Text("Copy")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.warmGray600)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Share button
                        Button {
                            showShareSheet = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                Text("Share")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.warmGray600)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 40)
                }
                .background(Color.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundColor(.warmGray600)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        if let url = recording.resolvedURL {
                            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.keyWindow?.rootViewController {
                                rootVC.present(activityVC, animated: true)
                            }
                        }
                    } label: {
                        Label("Export Audio", systemImage: "square.and.arrow.up.fill")
                    }
                    
                    Button {
                        showEditTitle = true
                        newTitle = recording.title
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.warmGray600)
                        .rotationEffect(.degrees(90))
                }
            }
        }
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showShareSheet) {
            if let url = recording.resolvedURL {
                ShareSheet(items: [recording.fullText, url])
            } else {
                ShareSheet(items: [recording.fullText])
            }
        }
        .alert("Note", isPresented: $showNotePopup) {
            Button("OK", role: .cancel) {}
        } message: {
            if !recording.notes.isEmpty {
                Text(recording.notes)
            } else {
                Text("No notes")
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
