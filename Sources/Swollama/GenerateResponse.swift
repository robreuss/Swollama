import Foundation

// Update GenerateResponse.swift
public struct GenerateResponse: Codable, Sendable {
    public let model: String
    public let createdAt: Date
    public let response: String
    public let done: Bool
    public let doneReason: String?
    public let context: [Int]?
    public let totalDuration: UInt64?
    public let loadDuration: UInt64?
    public let promptEvalCount: Int?
    public let promptEvalDuration: UInt64?
    public let evalCount: Int?
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        model = try container.decode(String.self, forKey: .model)
        response = try container.decode(String.self, forKey: .response)
        done = try container.decode(Bool.self, forKey: .done)
        doneReason = try container.decodeIfPresent(String.self, forKey: .doneReason)
        context = try container.decodeIfPresent([Int].self, forKey: .context)
        totalDuration = try container.decodeIfPresent(UInt64.self, forKey: .totalDuration)
        loadDuration = try container.decodeIfPresent(UInt64.self, forKey: .loadDuration)
        promptEvalCount = try container.decodeIfPresent(Int.self, forKey: .promptEvalCount)
        promptEvalDuration = try container.decodeIfPresent(UInt64.self, forKey: .promptEvalDuration)
        evalCount = try container.decodeIfPresent(Int.self, forKey: .evalCount)
        evalDuration = try container.decodeIfPresent(UInt64.self, forKey: .evalDuration)

        // Custom date decoding
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"  // Note the 6 decimal places for microseconds
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            // Try alternative format without microseconds
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath + [CodingKeys.createdAt],
                        debugDescription: "Date string '\(dateString)' does not match expected format",
                        underlyingError: nil
                    )
                )
            }
        }
    }
}

/// Response from a chat completion request
public struct ChatResponse: Codable, Sendable {
    public let model: String
    public let createdAt: Date
    public let message: ChatMessage
    public let done: Bool
    public let totalDuration: UInt64?
    public let loadDuration: UInt64?
    public let promptEvalCount: Int?
    public let promptEvalDuration: UInt64?
    public let evalCount: Int?
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        model = try container.decode(String.self, forKey: .model)
        message = try container.decode(ChatMessage.self, forKey: .message)
        done = try container.decode(Bool.self, forKey: .done)
        totalDuration = try container.decodeIfPresent(UInt64.self, forKey: .totalDuration)
        loadDuration = try container.decodeIfPresent(UInt64.self, forKey: .loadDuration)
        promptEvalCount = try container.decodeIfPresent(Int.self, forKey: .promptEvalCount)
        promptEvalDuration = try container.decodeIfPresent(UInt64.self, forKey: .promptEvalDuration)
        evalCount = try container.decodeIfPresent(Int.self, forKey: .evalCount)
        evalDuration = try container.decodeIfPresent(UInt64.self, forKey: .evalDuration)

        // Custom date decoding
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"  // Note the 6 decimal places for microseconds
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            // Try alternative format without microseconds
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath + [CodingKeys.createdAt],
                        debugDescription: "Date string '\(dateString)' does not match expected format",
                        underlyingError: nil
                    )
                )
            }
        }
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
