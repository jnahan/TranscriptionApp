import SwiftUI

struct NewRecordingSheet: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Callbacks
    var onRecordAudio: () -> Void
    var onUploadFile: () -> Void
    var onChooseFromPhotos: () -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background with blur
            Color.clear
                .background(.ultraThinMaterial)
                .background(Color.warmGray300.opacity(0.6))
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    closeButton
                    
                    actionButtons
                }
            }
        }
    }
    
    // MARK: - Subviews
    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 1) {
            ActionButton(
                iconName: "microphone",
                title: "Record audio",
                action: {
                    dismiss()
                    onRecordAudio()
                }
            )
            
            Divider()
                .padding(.leading, 60)
            
            ActionButton(
                iconName: "file",
                title: "Upload file",
                action: {
                    dismiss()
                    onUploadFile()
                }
            )
            
            Divider()
                .padding(.leading, 60)
            
            ActionButton(
                iconName: "image",
                title: "Upload video",
                action: {
                    dismiss()
                    onChooseFromPhotos()
                }
            )
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .padding()
    }
}

// MARK: - Action Button
private struct ActionButton: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .frame(width: 30)
                Text(title)
                    .font(.body)
                Spacer()
            }
            .foregroundColor(.primary)
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}
