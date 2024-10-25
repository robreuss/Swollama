import Foundation

/// Represents errors that can occur when interacting with the Ollama API.
public enum OllamaError: LocalizedError {
    /// The server returned an invalid or unexpected response.
    case invalidResponse
    
    /// The server returned a response that couldn't be decoded.
    case decodingError(Error)
    
    /// The server returned an error response.
    case serverError(String)
    
    /// The requested model was not found.
    case modelNotFound
    
    /// The operation was cancelled.
    case cancelled
    
    /// A network error occurred.
    case networkError(Error)
    
    /// The server returned an unexpected status code.
    case unexpectedStatusCode(Int)
    
    /// The provided parameters were invalid.
    case invalidParameters(String)
    
    /// An error occurred while handling a file.
    case fileError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response"
        case .decodingError(let error): "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message): "Server error: \(message)"
        case .modelNotFound: "The requested model was not found"
        case .cancelled: "The operation was cancelled"
        case .networkError(let error): "Network error: \(error.localizedDescription)"
        case .unexpectedStatusCode(let code): "Unexpected status code: \(code)"
        case .invalidParameters(let message): "Invalid parameters: \(message)"
        case .fileError(let message): "File error: \(message)"
        }
    }
}
