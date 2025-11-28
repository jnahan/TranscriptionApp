import SwiftUI

struct AudioPlayerControls: View {
    @ObservedObject var audioPlayer: AudioPlayerController
    let audioURL: URL?
    let fullText: String
    var onNotePressed: () -> Void
    var onSharePressed: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            VStack(spacing: 12) {
                Slider(value: $audioPlayer.currentTime, in: 0...max(audioPlayer.duration, 0.1)) { editing in
                    if !editing {
                        audioPlayer.seek(to: audioPlayer.currentTime)
                    }
                }
                .tint(.baseBlack)
                
                HStack {
                    Text(formatTime(audioPlayer.currentTime))
                        .font(.system(size: 16))
                        .foregroundColor(.warmGray500)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text(formatTime(audioPlayer.duration))
                        .font(.system(size: 16))
                        .foregroundColor(.warmGray500)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            
            // Bottom Action Buttons - Centered Group
            HStack(spacing: 24) {
                // Note button group (icon + text)
                Button {
                    onNotePressed()
                } label: {
                    HStack(spacing: 6) {
                        Image("note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("Note")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.warmGray500)
                }
                
                // Center playback controls (white pill)
                HStack(spacing: 0) {
                    // Rewind button
                    Button {
                        audioPlayer.skip(by: -15)
                    } label: {
                        Image("clock-counter-clockwise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.warmGray500)
                    }
                    .frame(width: 44, height: 40)
                    
                    // Play/Pause
                    Button {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            if let url = audioURL {
                                audioPlayer.play(url: url)
                            }
                        }
                    } label: {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.baseBlack)
                    }
                    .frame(width: 56, height: 40)
                    
                    // Forward button
                    Button {
                        audioPlayer.skip(by: 15)
                    } label: {
                        Image("clock-clockwise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.warmGray500)
                    }
                    .frame(width: 44, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.1), radius: 16, y: 4)
                
                // Copy and Export buttons group
                HStack(spacing: 20) {
                    // Copy button
                    Button {
                        UIPasteboard.general.string = fullText
                    } label: {
                        Image("copy")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.warmGray500)
                    }
                    
                    // Export/Share button
                    Button {
                        onSharePressed()
                    } label: {
                        Image("export")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.warmGray500)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)
        }
        .background(Color.warmGray50)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
