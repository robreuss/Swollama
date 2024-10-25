import Foundation

extension OllamaClient {
    /// Generates text from a prompt
    /// - Parameters:
    ///   - prompt: The prompt to generate from
    ///   - model: The model to use
    ///   - options: Additional generation options
    /// - Returns: An async sequence of generation responses
    public func generateText(
        prompt: String,
        model: OllamaModelName,
        options: GenerationOptions = .default
    ) async throws -> AsyncThrowingStream<GenerateResponse, Error> {
        let request = GenerateRequest(
            model: model.fullName,
            prompt: prompt,
            suffix: options.suffix,
            images: options.images,
            format: options.format,
            options: options.modelOptions,
            system: options.systemPrompt,
            template: options.template,
            context: options.context,
            stream: true,
            raw: options.raw,
            keepAlive: options.keepAlive ?? configuration.defaultKeepAlive
        )
        
        return streamRequest(
            endpoint: "generate",
            method: "POST",
            body: try encode(request),
            as: GenerateResponse.self
        )
    }
    
    /// Generates chat completions
    /// - Parameters:
    ///   - messages: The conversation messages
    ///   - model: The model to use
    ///   - options: Additional chat options
    /// - Returns: An async sequence of chat responses
    public func chat(
        messages: [ChatMessage],
        model: OllamaModelName,
        options: ChatOptions = .default
    ) async throws -> AsyncThrowingStream<ChatResponse, Error> {
        let request = ChatRequest(
            model: model.fullName,
            messages: messages,
            tools: options.tools,
            format: options.format,
            options: options.modelOptions,
            stream: true,
            keepAlive: options.keepAlive ?? configuration.defaultKeepAlive
        )
        
        return streamRequest(
            endpoint: "chat",
            method: "POST",
            body: try encode(request),
            as: ChatResponse.self
        )
    }
    
    /// Generates embeddings for text
    /// - Parameters:
    ///   - input: Text to generate embeddings for
    ///   - model: The model to use
    ///   - options: Additional embedding options
    /// - Returns: The generated embeddings
    public func generateEmbeddings(
        input: EmbeddingInput,
        model: OllamaModelName,
        options: EmbeddingOptions = .default
    ) async throws -> EmbeddingResponse {
        let request = EmbeddingRequest(
            model: model.fullName,
            input: input,
            truncate: options.truncate,
            options: options.modelOptions,
            keepAlive: options.keepAlive ?? configuration.defaultKeepAlive
        )
        
        let data = try await makeRequest(
            endpoint: "embeddings",
            method: "POST",
            body: try encode(request)
        )
        
        return try decode(data, as: EmbeddingResponse.self)
    }
}

/// Options for text generation
public struct GenerationOptions {
    public let suffix: String?
    public let images: [String]?
    public let format: ResponseFormat?
    public let modelOptions: ModelOptions?
    public let systemPrompt: String?
    public let template: String?
    public let context: [Int]?
    public let raw: Bool?
    public let keepAlive: TimeInterval?
    
    public init(
        suffix: String? = nil,
        images: [String]? = nil,
        format: ResponseFormat? = nil,
        modelOptions: ModelOptions? = nil,
        systemPrompt: String? = nil,
        template: String? = nil,
        context: [Int]? = nil,
        raw: Bool? = nil,
        keepAlive: TimeInterval? = nil
    ) {
        self.suffix = suffix
        self.images = images
        self.format = format
        self.modelOptions = modelOptions
        self.systemPrompt = systemPrompt
        self.template = template
        self.context = context
        self.raw = raw
        self.keepAlive = keepAlive
    }
    
    public static let `default` = GenerationOptions()
}

/// Options for chat completion
public struct ChatOptions {
    public let tools: [ToolDefinition]?
    public let format: ResponseFormat?
    public let modelOptions: ModelOptions?
    public let keepAlive: TimeInterval?
    
    public init(
        tools: [ToolDefinition]? = nil,
        format: ResponseFormat? = nil,
        modelOptions: ModelOptions? = nil,
        keepAlive: TimeInterval? = nil
    ) {
        self.tools = tools
        self.format = format
        self.modelOptions = modelOptions
        self.keepAlive = keepAlive
    }
    
    public static let `default` = ChatOptions()
}

/// Options for embedding generation
public struct EmbeddingOptions {
    public let truncate: Bool?
    public let modelOptions: ModelOptions?
    public let keepAlive: TimeInterval?
    
    public init(
        truncate: Bool? = true,
        modelOptions: ModelOptions? = nil,
        keepAlive: TimeInterval? = nil
    ) {
        self.truncate = truncate
        self.modelOptions = modelOptions
        self.keepAlive = keepAlive
    }
    
    public static let `default` = EmbeddingOptions()
}
