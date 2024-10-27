import Foundation

/// A response from a text generation request.
/// - Note: This struct includes both the generated text and various performance metrics.
public struct GenerateResponse: Codable, Sendable {
    /// The identifier of the model used for generation.
    public let model: String

    /// The timestamp when the response was generated.
    public let createdAt: Date

    /// The generated text response.
    public let response: String

    /// Indicates whether the generation is complete.
    public let done: Bool

    /// The reason why generation was completed, if applicable.
    public let doneReason: String?

    /// Context tokens used during generation.
    public let context: [Int]?

    /// The total time taken for generation, in microseconds.
    public let totalDuration: UInt64?

    /// The time taken to load the model, in microseconds.
    public let loadDuration: UInt64?

    /// The number of prompt evaluations performed.
    public let promptEvalCount: Int?

    /// The time spent evaluating prompts, in microseconds.
    public let promptEvalDuration: UInt64?

    /// The total number of evaluations performed.
    public let evalCount: Int?

    /// The total time spent on evaluations, in microseconds.
    public let evalDuration: UInt64?

    /// Mapping between property names and JSON keys.
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

    /// Creates a new generate response by decoding from the given decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError` if the data is corrupted or any required keys are missing.
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
