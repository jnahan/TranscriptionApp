import Foundation

extension String {
    /// Returns the string with leading and trailing whitespace removed
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns true if the string is empty or contains only whitespace
    var isBlank: Bool {
        trimmed.isEmpty
    }
}
