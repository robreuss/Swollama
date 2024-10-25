import Foundation

/// Configuration options for the Ollama client.
public struct OllamaConfiguration {
    /// The timeout interval for requests in seconds
    public let timeoutInterval: TimeInterval
    
    /// The maximum number of retry attempts for failed requests
    public let maxRetries: Int
    
    /// The retry delay interval in seconds
    public let retryDelay: TimeInterval
    
    /// Whether to allow insecure connections (not recommended for production)
    public let allowsInsecureConnections: Bool
    
    /// The default keep-alive duration for models
    public let defaultKeepAlive: TimeInterval
    
    /// Creates a new configuration with the specified options
    /// - Parameters:
    ///   - timeoutInterval: The timeout interval in seconds (default: 30)
    ///   - maxRetries: Maximum number of retry attempts (default: 3)
    ///   - retryDelay: Delay between retries in seconds (default: 1)
    ///   - allowsInsecureConnections: Whether to allow insecure connections (default: false)
    ///   - defaultKeepAlive: Default keep-alive duration in seconds (default: 300)
    public init(
        timeoutInterval: TimeInterval = 30,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1,
        allowsInsecureConnections: Bool = false,
        defaultKeepAlive: TimeInterval = 300
    ) {
        self.timeoutInterval = timeoutInterval
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        self.allowsInsecureConnections = allowsInsecureConnections
        self.defaultKeepAlive = defaultKeepAlive
    }
    
    /// The default configuration
    public static let `default` = OllamaConfiguration()
}
