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
                Text("Folder name")
                    .font(.system(size: 14))
                    .foregroundColor(.warmGray500)
                    .padding(.horizontal, 24)
                
                TextField("Folder name", text: $folderName)
                    .font(.system(size: 17))
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .focused($isTextFieldFocused)
            }
            
            Spacer()
            
            // Create button
            Button {
                onCreate()
                isPresented = false
            } label: {
                Text("Create folder")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(folderName.isEmpty ? Color.warmGray400 : Color.black)
                    .cornerRadius(16)
            }
            .disabled(folderName.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(Color.warmGray50)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Automatically focus the text field when the sheet appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
}
