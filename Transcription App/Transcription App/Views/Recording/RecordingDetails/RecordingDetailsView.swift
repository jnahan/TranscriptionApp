import SwiftUI
import SwiftData
import AVFoundation

struct RecordingDetailsView: View {
    let recording: Recording
    @StateObject private var audioPlayer = Player()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var collections: [Collection]
    
    @State private var showNotePopup = false
    @State private var showEditRecording = false
    @State private var showDeleteConfirm = false
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            Color.warmGray50
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Top Bar
                CustomTopBar(
                    title: "",
                    leftIcon: "caret-left",
                    rightIcon: "dots-three",
                    onLeftTap: { dismiss() },
                    onRightTap: { showMenu = true }
                )
                
                // Header
                VStack(spacing: 12) {
                    Image("asterisk")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)

                    VStack(spacing: 8) {
                        Text(TimeFormatter.relativeDate(from: recording.recordedAt))
                            .font(.system(size: 14))
                            .foregroundColor(.warmGray500)
                        
                        Text(recording.title)
                            .font(.custom("LibreBaskerville-Medium", size: 24))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                
                // Scrollable Transcript Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if !recording.segments.isEmpty {
                            ForEach(recording.segments.sorted(by: { $0.start < $1.start })) { segment in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(TimeFormatter.formatTimestamp(segment.start))
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(.warmGray400)
                                        .monospacedDigit()
                                    
                                    Text(segment.text)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(.baseBlack)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if let url = recording.resolvedURL {
                                        // If already playing, just seek. Otherwise load, seek, and play.
                                        if audioPlayer.isPlaying {
                                            audioPlayer.seek(toTime: segment.start)
                                        } else {
                                            audioPlayer.loadAudio(url: url)
                                            audioPlayer.seek(toTime: segment.start)
                                            audioPlayer.play(url)
                                        }
                                    }
                                }
                            }
                        } else {
                            // Show full text with a single timestamp at the top
                            VStack(alignment: .leading, spacing: 4) {
                                Text("0:00")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.warmGray400)
                                    .monospacedDigit()
                                
                            Text(recording.fullText)
                                    .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.baseBlack)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppConstants.UI.Spacing.large)
                    .padding(.top, 24)
                    .padding(.bottom, 180)
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
                        if let url = recording.resolvedURL {
                            ShareHelper.shareItems([recording.fullText, url])
                        } else {
                            ShareHelper.shareText(recording.fullText)
                        }
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
        .confirmationDialog("", isPresented: $showMenu, titleVisibility: .hidden) {
            Button("Copy transcription") {
                UIPasteboard.general.string = recording.fullText
            }
            
            Button("Share transcription") {
                ShareHelper.shareText(recording.fullText)
            }
            
            Button("Export audio") {
                if let url = recording.resolvedURL {
                    ShareHelper.shareFile(at: url)
                }
            }
            
            Button("Edit") {
                showEditRecording = true
            }
            
            Button("Delete", role: .destructive) {
                showDeleteConfirm = true
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showEditRecording) {
            RecordingFormView(
                isPresented: $showEditRecording,
                audioURL: nil,
                existingRecording: recording,
                collections: collections,
                modelContext: modelContext,
                onTranscriptionComplete: {},
                onExit: nil
            )
        }
        .sheet(isPresented: $showDeleteConfirm) {
            ConfirmationSheet(
                isPresented: $showDeleteConfirm,
                title: "Delete recording?",
                message: "Are you sure you want to delete \"\(recording.title)\"? This action cannot be undone.",
                confirmButtonText: "Delete recording",
                cancelButtonText: "Cancel",
                onConfirm: {
                    modelContext.delete(recording)
                    showDeleteConfirm = false
                    dismiss()
                }
            )
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
}
