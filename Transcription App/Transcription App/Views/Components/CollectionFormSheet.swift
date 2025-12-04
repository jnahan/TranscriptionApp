import SwiftUI
import SwiftData

struct CollectionFormSheet: View {
    @Binding var isPresented: Bool
    @Binding var folderName: String
    let isEditing: Bool
    let onSave: () -> Void
    let existingFolders: [Folder]
    let currentFolder: Folder?
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var folderNameError: String? = nil
    @State private var hasAttemptedSubmit = false
    
    private var isFormValid: Bool {
        validateFolderName()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.warmGray300)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Title
            Text(isEditing ? "Rename folder" : "Create folder")
                .font(.custom("LibreBaskerville-Regular", size: 24))
                .foregroundColor(.baseBlack)
                .padding(.bottom, 32)
            
            // Text field
            VStack(alignment: .leading, spacing: 8) {
                InputLabel(text: "Folder name")
                    .padding(.horizontal, 24)
                
                InputField(
                    text: $folderName,
                    placeholder: "Folder name",
                    error: folderNameError
                )
                .padding(.horizontal, 24)
                .focused($isTextFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    hasAttemptedSubmit = true
                    validateFolderNameWithError()
                    if isFormValid {
                        onSave()
                        isPresented = false
                    }
                }
            }
            .padding(.bottom, 32)
            
            // Save button
            Button {
                hasAttemptedSubmit = true
                validateFolderNameWithError()
                if isFormValid {
                    onSave()
                    isPresented = false
                }
            } label: {
                Text(isEditing ? "Save changes" : "Create folder")
            }
            .buttonStyle(AppButtonStyle())
        }
        .background(Color.warmGray100)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.warmGray100)
        .presentationCornerRadius(24)
        .onAppear {
            #if !os(macOS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
            #endif
        }
    }
    
    // MARK: - Validation Functions
    
    private func validateFolderName() -> Bool {
        let trimmed = folderName.trimmed
        
        if trimmed.isEmpty {
            return false
        }
        
        if trimmed.count > AppConstants.Validation.maxCollectionNameLength {
            return false
        }
        
        // Get existing names, excluding current folder if editing
        let existingNames = existingFolders.compactMap { folder -> String? in
            if isEditing, let currentFolder = currentFolder, folder.id == currentFolder.id {
                return nil
            }
            return folder.name
        }
        
        return ValidationHelper.validateUnique(trimmed, against: existingNames, fieldName: "collection") == nil
    }
    
    @discardableResult
    private func validateFolderNameWithError() -> Bool {
        if hasAttemptedSubmit {
            let trimmed = folderName.trimmed
            
            // Validate not empty
            if let error = ValidationHelper.validateNotEmpty(trimmed, fieldName: "Collection name") {
                folderNameError = error
                return false
            }
            
            // Validate length
            if let error = ValidationHelper.validateLength(trimmed, max: AppConstants.Validation.maxCollectionNameLength, fieldName: "Collection name") {
                folderNameError = error
                return false
            }
            
            // Get existing names, excluding current folder if editing
            let existingNames = existingFolders.compactMap { folder -> String? in
                if isEditing, let currentFolder = currentFolder, folder.id == currentFolder.id {
                    return nil
                }
                return folder.name
            }
            
            // Validate uniqueness
            if let error = ValidationHelper.validateUnique(trimmed, against: existingNames, fieldName: "collection") {
                folderNameError = error
                return false
            }
            
            folderNameError = nil
            return true
        } else {
            // Don't show errors until submit is attempted
            folderNameError = nil
            return validateFolderName()
        }
    }
}
