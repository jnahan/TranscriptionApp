import SwiftUI

struct NoteOverlay: View {
    @Binding var isPresented: Bool
    let noteText: String
    
    var body: some View {
        ZStack {
            // Background with blur
            Color.clear
                .background(.ultraThinMaterial)
                .background(Color.warmGray300.opacity(0.6))
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    
                    // Note content
                    VStack(spacing: 8) {
                        // Push pin icon
                        Image("push-pin-fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.accent)
                        
                        // Note text
                        Text(noteText.isEmpty ? "No notes" : noteText)
                            .font(.system(size: 16))
                            .foregroundColor(.baseBlack)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 24)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
    }
}
