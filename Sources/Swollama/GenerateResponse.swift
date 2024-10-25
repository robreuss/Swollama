import Foundation

// Update GenerateResponse.swift
public struct GenerateResponse: Codable, Sendable {
    /// The model used for generation
    public let model: String
    /// The creation timestamp
    public let createdAt: Date
    /// The generated response
    public let response: String
    /// Whether generation is complete
    public let done: Bool
    /// The reason for completion
    public let doneReason: String?
    /// Context for conversation continuation
    public let context: [Int]?
    /// Total duration in nanoseconds
    public let totalDuration: UInt64?
    /// Load duration in nanoseconds
    public let loadDuration: UInt64?
    /// Number of prompt tokens
    public let promptEvalCount: Int?
    /// Time spent evaluating prompt in nanoseconds
    public let promptEvalDuration: UInt64?
    /// Number of generated tokens
    public let evalCount: Int?
    /// Time spent generating in nanoseconds
    public let evalDuration: UInt64?

    private enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case response
        case done
        case doneReason = "done_reason"
        case context
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}

/// Response from a chat completion request
public struct ChatResponse: Codable, Sendable {
    /// The model used for chat
    public let model: String
    /// The creation timestamp
    public let createdAt: Date
    /// The message from the assistant
    public let message: ChatMessage
    /// Whether the response is complete
    public let done: Bool
    /// Total duration in nanoseconds
    public let totalDuration: UInt64?
    /// Load duration in nanoseconds
    public let loadDuration: UInt64?
    /// Number of prompt tokens
    public let promptEvalCount: Int?
    /// Time spent evaluating prompt in nanoseconds
    public let promptEvalDuration: UInt64?
    /// Number of generated tokens
    public let evalCount: Int?
    /// Time spent generating in nanoseconds
    public let evalDuration: UInt64?

    private enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case message
        case done
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}

/// Response from an embedding generation request
public struct EmbeddingResponse: Codable, Sendable {
    /// The model used for embeddings
    public let model: String
    /// The generated embeddings
    public let embeddings: [[Double]]
    /// Total duration in nanoseconds
    public let totalDuration: UInt64?
    /// Load duration in nanoseconds
    public let loadDuration: UInt64?
    /// Number of prompt tokens
    public let promptEvalCount: Int?

    private enum CodingKeys: String, CodingKey {
        case model
        case embeddings
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
    }
}
