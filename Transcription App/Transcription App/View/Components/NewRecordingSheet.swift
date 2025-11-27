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
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                closeButton
                
                actionButtons
            }
            .background(Color.black.opacity(0.0001))
        }
        .background(backgroundDismiss)
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
                icon: "mic.fill",
                title: "Record audio",
                action: {
                    dismiss()
                    onRecordAudio()
                }
            )
            
            Divider()
                .padding(.leading, 60)
            
            ActionButton(
                icon: "arrow.up.doc.fill",
                title: "Upload from files",
                action: {
                    dismiss()
                    onUploadFile()
                }
            )
            
            Divider()
                .padding(.leading, 60)
            
            ActionButton(
                icon: "photo.on.rectangle",
                title: "Choose from photos",
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
    
    private var backgroundDismiss: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
    }
}

// MARK: - Action Button
private struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
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
