import UIKit

/// Utility for sharing content and files
struct ShareHelper {
    
    /// Share text content using the system share sheet
    /// - Parameter text: The text to share
    static func shareText(_ text: String) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        presentActivityController(activityVC)
    }
    
    /// Share a file using the system share sheet
    /// - Parameter url: The URL of the file to share
    static func shareFile(at url: URL) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        presentActivityController(activityVC)
    }
    
    // MARK: - Private Helpers
    
    private static func presentActivityController(_ activityVC: UIActivityViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        rootVC.present(activityVC, animated: true)
    }
}
