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
public enum ResponseFormat: String, Codable {
    case json
}

/// Parameters for chat completion requests.
public struct ChatRequest: Codable, Sendable {
    public init(model: String, messages: [ChatMessage], tools: [ToolDefinition]? = nil, format: ResponseFormat? = nil, options: ModelOptions? = nil, stream: Bool? = nil, keepAlive: TimeInterval? = nil) {
        self.model = model
        self.messages = messages
        self.tools = tools
        self.format = format
        self.options = options
        self.stream = stream
        self.keepAlive = keepAlive
    }
    
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
    public init(role: MessageRole, content: String, images: [String]? = nil, toolCalls: [ToolCall]? = nil) {
        self.role = role
        self.content = content
        self.images = images
        self.toolCalls = toolCalls
    }

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
public enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    case tool
}

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

/// Update ModelOptions.swift to fix missing fields
public struct ModelOptions: Codable, Sendable {
    public let numKeep: Int?
    public let seed: UInt32?
    public let numPredict: Int?
    public let topK: Int?
    public let topP: Double?
    public let minP: Double?
    public let tfsZ: Double?
    public let typicalP: Double?
    public let repeatLastN: Int?
    public let temperature: Double?
    public let repeatPenalty: Double?
    public let presencePenalty: Double?
    public let frequencyPenalty: Double?
    public let mirostat: Int?
    public let mirostatTau: Double?
    public let mirostatEta: Double?
    public let penalizeNewline: Bool?
    public let stop: [String]?
    public let numa: Bool?
    public let numCtx: Int?
    public let numBatch: Int?
    public let numGPU: Int?
    public let mainGPU: Int?
    public let lowVRAM: Bool?
    public let f16KV: Bool?
    public let vocabOnly: Bool?
    public let useMMap: Bool?
    public let useMLock: Bool?
    public let numThread: Int?

    private enum CodingKeys: String, CodingKey {
        case numKeep = "num_keep"
        case seed
        case numPredict = "num_predict"
        case topK = "top_k"
        case topP = "top_p"
        case minP = "min_p"
        case tfsZ = "tfs_z"
        case typicalP = "typical_p"
        case repeatLastN = "repeat_last_n"
        case temperature
        case repeatPenalty = "repeat_penalty"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case mirostat
        case mirostatTau = "mirostat_tau"
        case mirostatEta = "mirostat_eta"
        case penalizeNewline = "penalize_newline"
        case stop
        case numa
        case numCtx = "num_ctx"
        case numBatch = "num_batch"
        case numGPU = "num_gpu"
        case mainGPU = "main_gpu"
        case lowVRAM = "low_vram"
        case f16KV = "f16_kv"
        case vocabOnly = "vocab_only"
        case useMMap = "use_mmap"
        case useMLock = "use_mlock"
        case numThread = "num_thread"
    }

    public init(
        numKeep: Int? = nil,
        seed: UInt32? = nil,
        numPredict: Int? = nil,
        topK: Int? = nil,
        topP: Double? = nil,
        minP: Double? = nil,
        tfsZ: Double? = nil,
        typicalP: Double? = nil,
        repeatLastN: Int? = nil,
        temperature: Double? = nil,
        repeatPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        mirostat: Int? = nil,
        mirostatTau: Double? = nil,
        mirostatEta: Double? = nil,
        penalizeNewline: Bool? = nil,
        stop: [String]? = nil,
        numa: Bool? = nil,
        numCtx: Int? = nil,
        numBatch: Int? = nil,
        numGPU: Int? = nil,
        mainGPU: Int? = nil,
        lowVRAM: Bool? = nil,
        f16KV: Bool? = nil,
        vocabOnly: Bool? = nil,
        useMMap: Bool? = nil,
        useMLock: Bool? = nil,
        numThread: Int? = nil
    ) {
        self.numKeep = numKeep
        self.seed = seed
        self.numPredict = numPredict
        self.topK = topK
        self.topP = topP
        self.minP = minP
        self.tfsZ = tfsZ
        self.typicalP = typicalP
        self.repeatLastN = repeatLastN
        self.temperature = temperature
        self.repeatPenalty = repeatPenalty
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.mirostat = mirostat
        self.mirostatTau = mirostatTau
        self.mirostatEta = mirostatEta
        self.penalizeNewline = penalizeNewline
        self.stop = stop
        self.numa = numa
        self.numCtx = numCtx
        self.numBatch = numBatch
        self.numGPU = numGPU
        self.mainGPU = mainGPU
        self.lowVRAM = lowVRAM
        self.f16KV = f16KV
        self.vocabOnly = vocabOnly
        self.useMMap = useMMap
        self.useMLock = useMLock
        self.numThread = numThread
    }
}
