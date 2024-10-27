import Foundation

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
