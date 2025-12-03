import SwiftUI
import SwiftData

struct CreateFolderSheet: View {
    @Binding var isPresented: Bool
    @Binding var folderName: String
    let onCreate: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.warmGray300)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Title
            Text("Create folder")
                .font(.custom("LibreBaskerville-Regular", size: 24))
                .foregroundColor(.baseBlack)
                .padding(.bottom, 32)
            
            // Text field
            VStack(alignment: .leading, spacing: 8) {
                InputLabel(text: "Folder name")
                    .padding(.horizontal, 24)
                
                InputField(text: $folderName, placeholder: "Folder name")
                    .padding(.horizontal, 24)
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if !folderName.isEmpty {
                            onCreate()
                            isPresented = false
                        }
                    }
            }
            .padding(.bottom, 32)
            
            // Create button
            Button {
                onCreate()
                isPresented = false
            } label: {
                Text("Create folder")
            }
            .disabled(folderName.isEmpty)
            .buttonStyle(AppButtonStyle())
        }
        .background(Color.warmGray50)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
