import SwiftUI
import UniformTypeIdentifiers

struct AudioFilePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var onFilePicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Support common audio formats
        let supportedTypes: [UTType] = [
            .audio,
            .mp3,
            .mpeg4Audio,
            UTType(filenameExtension: "m4a") ?? .audio,
            UTType(filenameExtension: "wav") ?? .audio,
            UTType(filenameExtension: "aiff") ?? .audio,
            UTType(filenameExtension: "aif") ?? .audio,
            UTType(filenameExtension: "caf") ?? .audio
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: AudioFilePicker
        
        init(_ parent: AudioFilePicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Copy the file to app's directory
            do {
                let fileManager = FileManager.default
                let documentsURL = try fileManager.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                ).appendingPathComponent("Recordings", isDirectory: true)
                
                // Create Recordings directory if it doesn't exist
                try? fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true)
                
                // Create unique filename
                let filename = url.lastPathComponent
                let destinationURL = documentsURL.appendingPathComponent(filename)
                
                // If file exists, add timestamp to make it unique
                var finalURL = destinationURL
                if fileManager.fileExists(atPath: destinationURL.path) {
                    let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
                    let name = url.deletingPathExtension().lastPathComponent
                    let ext = url.pathExtension
                    finalURL = documentsURL.appendingPathComponent("\(name)-\(timestamp).\(ext)")
                }
                
                // Copy the file
                try fileManager.copyItem(at: url, to: finalURL)
                
                // Call the completion handler with the copied file URL
                DispatchQueue.main.async {
                    self.parent.onFilePicked(finalURL)
                }
                
            } catch {
                print("Error copying file: \(error)")
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Picker was cancelled, just dismiss
        }
    }
}
