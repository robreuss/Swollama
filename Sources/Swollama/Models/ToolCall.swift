import Foundation

/// Represents a tool call made by the model
public struct ToolCall: Codable, Sendable {
    /// The function that was called
    public let function: FunctionCall
    
    public init(function: FunctionCall) {
        self.function = function
    }
}

/// Represents a function call made by the model
public struct FunctionCall: Codable, Sendable {
    /// The name of the function that was called
    public let name: String
    /// The arguments provided to the function
    public let arguments: String
    
    public init(name: String, arguments: String) {
        self.name = name
        self.arguments = arguments
    }
}
