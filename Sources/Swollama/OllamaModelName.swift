import Foundation

/// A type-safe representation of an Ollama model name
public struct OllamaModelName {
    /// The namespace of the model (optional)
    public let namespace: String?
    /// The name of the model
    public let name: String
    /// The tag of the model (defaults to "latest")
    public let tag: String

    /// Creates a new model name
    /// - Parameters:
    ///   - namespace: The optional namespace
    ///   - name: The model name
    ///   - tag: The tag (defaults to "latest")
    public init(namespace: String? = nil, name: String, tag: String = "latest") {
        self.namespace = namespace
        self.name = name
        self.tag = tag
    }

    /// Creates a model name from a string in the format "namespace/name:tag"
    /// - Parameter string: The string to parse
    /// - Returns: A new model name, or nil if the string is invalid
    public static func parse(_ string: String) -> OllamaModelName? {
        let components = string.split(separator: "/")
        switch components.count {
        case 1:
            let nameComponents = components[0].split(separator: ":")
            guard let name = nameComponents.first else { return nil }
            let tag = nameComponents.count > 1 ? String(nameComponents[1]) : "latest"
            return OllamaModelName(name: String(name), tag: tag)
        case 2:
            let nameComponents = components[1].split(separator: ":")
            guard let name = nameComponents.first else { return nil }
            let tag = nameComponents.count > 1 ? String(nameComponents[1]) : "latest"
            return OllamaModelName(namespace: String(components[0]), name: String(name), tag: tag)
        default:
            return nil
        }
    }

    /// Returns the full string representation of the model name
    public var fullName: String {
        if let namespace = namespace {
            return "\(namespace)/\(name):\(tag)"
        }
        return "\(name):\(tag)"
    }
}
