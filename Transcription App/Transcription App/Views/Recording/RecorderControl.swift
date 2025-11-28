import SwiftUI
import AVFoundation
import Combine
#if canImport(UIKit)
import UIKit
#endif

// MARK: - RecorderControl
struct RecorderControl: View {
    @StateObject private var rec = Recorder()
    @StateObject private var player = Player()
    @State private var micDenied = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var onFinishRecording: ((URL) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Timer display
            VStack(spacing: 20) {
                Text(formattedTime)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.baseBlack)
                    .monospacedDigit()
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(20)
                
                // Vertical line
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: 280)
            }
            
            // Waveform visualizer
            RecorderVisualizer(values: rec.meterHistory, barCount: 40)
                .frame(height: 60)
                .padding(.horizontal, 40)
                .padding(.top, -140)
            
            Spacer()
            
            // Bottom buttons
            HStack(spacing: 60) {
                // Retry button
                Button {
                    playTapHaptic()
                    resetRecording()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                        Text("Retry")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.accent)
                }
                .disabled(!rec.isRecording && rec.fileURL == nil)
                .opacity((!rec.isRecording && rec.fileURL == nil) ? 0.3 : 1)
                
                // Record/Stop button
                Button {
                    playTapHaptic()
                    if rec.isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 88, height: 88)
                            .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                        
                        if rec.isRecording {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accent)
                                .frame(width: 36, height: 36)
                        } else {
                            Circle()
                                .fill(Color.accent)
                                .frame(width: 72, height: 72)
                        }
                    }
                }
                
                // Done button
                Button {
                    playTapHaptic()
                    finishRecording()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20))
                        Text("Done")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.baseBlack)
                }
                .disabled(rec.fileURL == nil)
                .opacity(rec.fileURL == nil ? 0.3 : 1)
            }
            .padding(.bottom, 50)
        }
        .task {
            rec.requestPermission { ok in
                micDenied = (ok == false)
            }
        }
        .onChange(of: rec.isRecording) { _, isRecording in
            if isRecording {
                startTimer()
            } else {
                stopTimer()
            }
        }
        .alert("Microphone Access Needed", isPresented: $micDenied) {
            Button("OK", role: .cancel) {}
            #if canImport(UIKit)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            #endif
        } message: {
            Text("Please allow microphone access in Settings to record audio.")
        }
    }
    
    // MARK: - Computed Properties
    private var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Actions
    private func startRecording() {
        player.stop()
        elapsedTime = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rec.start()
        }
    }
    
    private func stopRecording() {
        rec.stop()
    }
    
    private func resetRecording() {
        if rec.isRecording {
            rec.stop()
        }
        elapsedTime = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            startRecording()
        }
    }
    
    private func finishRecording() {
        if rec.isRecording {
            rec.stop()
        }
        if let fileURL = rec.fileURL {
            onFinishRecording?(fileURL)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            elapsedTime += 0.01
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func playTapHaptic() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
