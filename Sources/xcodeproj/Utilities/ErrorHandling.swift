import Foundation

struct ValidationError: LocalizedError {
    let message: String
    
    var errorDescription: String? { message }
    
    static func invalidParams(_ message: String) -> ValidationError {
        ValidationError(message: message)
    }
    
    static func internalError(_ message: String) -> ValidationError {
        ValidationError(message: message)
    }
}

// Add FileHandle extension for stderr
extension FileHandle: @retroactive TextOutputStream {
    public func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.write(data)
        }
    }
}

nonisolated(unsafe) var standardError = FileHandle.standardError
