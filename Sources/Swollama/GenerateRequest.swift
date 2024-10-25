import Foundation

/// Parameters for text generation requests.
public struct GenerateRequest: Codable, Sendable {
    /// The model to use for generation
    public let model: String
    /// The prompt to generate text from
    public let prompt: String
    /// Optional additional text to append after generated text
    public let suffix: String?
    /// Optional list of base64-encoded images for multimodal models
    public let images: [String]?
    /// The format to return the response in
    public let format: ResponseFormat?
    /// Additional model parameters
    public let options: ModelOptions?
    /// System message to override Modelfile
    public let system: String?
    /// Template to use for generation
    public let template: String?
    /// Context from previous request for conversation
    public let context: [Int]?
    /// Whether to stream the response
    public let stream: Bool?
    /// Whether to use raw prompting
    public let raw: Bool?
    /// How long to keep model loaded in memory
    public let keepAlive: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case model, prompt, suffix, images, format, options, system
        case template, context, stream, raw
        case keepAlive = "keep_alive"
    }

    public init(
        model: String,
        prompt: String,
        suffix: String? = nil,
        images: [String]? = nil,
        format: ResponseFormat? = nil,
        options: ModelOptions? = nil,
        system: String? = nil,
        template: String? = nil,
        context: [Int]? = nil,
        stream: Bool? = nil,
        raw: Bool? = nil,
        keepAlive: TimeInterval? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.suffix = suffix
        self.images = images
        self.format = format
        self.options = options
        self.system = system
        self.template = template
        self.context = context
        self.stream = stream
        self.raw = raw
        self.keepAlive = keepAlive
    }
}

/// Response format options
public enum ResponseFormat: String, Codable, Sendable {
    case json
}

/// Parameters for chat completion requests.
public struct ChatRequest: Codable, Sendable {
    /// The model to use for chat
    public let model: String
    /// The messages in the conversation
    public let messages: [ChatMessage]
    /// Available tools for the model to use
    public let tools: [ToolDefinition]?
    /// The format to return the response in
    public let format: ResponseFormat?
    /// Additional model parameters
    public let options: ModelOptions?
    /// Whether to stream the response
    public let stream: Bool?
    /// How long to keep model loaded in memory
    public let keepAlive: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case model, messages, tools, format, options, stream
        case keepAlive = "keep_alive"
    }
}

/// A message in a chat conversation
public struct ChatMessage: Codable, Sendable {
    /// The role of the message sender
    public let role: MessageRole
    /// The content of the message
    public let content: String
    /// Optional images for multimodal models
    public let images: [String]?
    /// Tool calls made by the assistant
    public let toolCalls: [ToolCall]?

    private enum CodingKeys: String, CodingKey {
        case role, content, images
        case toolCalls = "tool_calls"
    }
}

/// Available message roles
public enum MessageRole: String, Codable, Sendable {
    case system
    case user
    case assistant
    case tool
}

/// Parameters for embedding generation requests
public struct EmbeddingRequest: Codable, Sendable {
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
