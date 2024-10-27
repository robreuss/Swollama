import Foundation

/// Parameters for embedding generation requests
public struct EmbeddingRequest: Codable, Sendable {
    public init(model: String, input: EmbeddingInput, truncate: Bool? = nil, options: ModelOptions? = nil, keepAlive: TimeInterval? = nil) {
        self.model = model
        self.input = input
        self.truncate = truncate
        self.options = options
        self.keepAlive = keepAlive
    }
    
    /// The model to use for embeddings
    public let model: String
    /// The text or array of text to generate embeddings for
    public let input: EmbeddingInput
    /// Whether to truncate input to fit context length
    public let truncate: Bool?
    /// Additional model parameters
    public let options: ModelOptions?
    /// How long to keep model loaded in memory
    public let keepAlive: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case model, input, truncate, options
        case keepAlive = "keep_alive"
    }
}

/// Input for embedding generation
public enum EmbeddingInput: Codable, Sendable {
    case single(String)
    case multiple([String])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let string):
            try container.encode(string)
        case .multiple(let array):
            try container.encode(array)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .single(string)
        } else if let array = try? container.decode([String].self) {
            self = .multiple(array)
        } else {
            throw DecodingError.typeMismatch(
                EmbeddingInput.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [String]"
                )
            )
        }
    }
}
