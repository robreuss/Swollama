import Foundation

/// Response structure for list models endpoint
struct ModelsResponse: Codable {
    let models: [ModelListEntry]
}

/// Entry returned from list models endpoint
public struct ModelListEntry: Codable, Sendable {
    /// Name of the model
    public let name: String
    /// Full model identifier
    public let model: String
    /// When the model was last modified
    public let modifiedAt: Date
    /// Size of the model in bytes
    public let size: UInt64
    /// SHA256 digest of the model
    public let digest: String
    /// Details about the model
    public let details: ModelDetails

    private enum CodingKeys: String, CodingKey {
        case name, model, size, digest, details
        case modifiedAt = "modified_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        model = try container.decode(String.self, forKey: .model)
        size = try container.decode(UInt64.self, forKey: .size)
        digest = try container.decode(String.self, forKey: .digest)
        details = try container.decode(ModelDetails.self, forKey: .details)

        // Custom date decoding
        let dateString = try container.decode(String.self, forKey: .modifiedAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: dateString) {
            modifiedAt = date
        } else {
            // Try alternative format without milliseconds
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: dateString) {
                modifiedAt = date
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath + [CodingKeys.modifiedAt],
                        debugDescription: "Date string '\(dateString)' does not match expected format",
                        underlyingError: nil
                    )
                )
            }
        }
    }
}

/// Model details shared across API responses
public struct ModelDetails: Codable, Sendable {
    /// Parent model name
    public let parentModel: String
    /// Model format (e.g., gguf)
    public let format: String
    /// Model family name 
    public let family: String
    /// All model families this model belongs to
    public let families: [String]?
    /// Parameter size (e.g., "7B")
    public let parameterSize: String
    /// Quantization level (e.g., "Q4_0")
    public let quantizationLevel: String
    
    private enum CodingKeys: String, CodingKey {
        case parentModel = "parent_model"
        case format, family, families
        case parameterSize = "parameter_size"
        case quantizationLevel = "quantization_level"
    }
}
