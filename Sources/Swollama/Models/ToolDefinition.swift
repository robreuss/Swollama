import Foundation

/// Represents a tool that can be used by the model
public struct ToolDefinition: Codable, Sendable {
    /// The type of the tool
    public let type: String
    /// The function definition
    public let function: FunctionDefinition

    public init(type: String = "function", function: FunctionDefinition) {
        self.type = type
        self.function = function
    }
}

/// Represents a function definition for a tool
public struct FunctionDefinition: Codable, Sendable {
    /// The name of the function
    public let name: String
    /// Description of what the function does
    public let description: String
    /// The parameters the function accepts
    public let parameters: Parameters

    public init(
        name: String,
        description: String,
        parameters: Parameters
    ) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

/// Represents the parameters for a function
public struct Parameters: Codable, Sendable {
    /// The type of the parameters object
    public let type: String
    /// The properties of the parameters
    public let properties: [String: PropertyDefinition]
    /// Required parameter names
    public let required: [String]

    public init(
        type: String = "object",
        properties: [String: PropertyDefinition],
        required: [String]
    ) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

/// Represents a property in a parameter definition
public struct PropertyDefinition: Codable, Sendable {
    /// The type of the property
    public let type: String
    /// Description of the property
    public let description: String
    /// Allowed values for enum types
    public let enumValues: [String]?

    public init(
        type: String,
        description: String,
        enumValues: [String]? = nil
    ) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case description
        case enumValues = "enum"
    }
}
