import Foundation

// MARK: - Model List Types

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

// MARK: - Show Model Types

/// Detailed model information returned from show endpoint
public struct ModelInformation: Codable, Sendable {
    /// The Modelfile content
    public let modelfile: String
    /// Model parameters
    public let parameters: String
    /// The template used for prompts
    public let template: String
    /// Details about the model
    public let details: ModelDetails
    /// Additional model information
    public let modelInfo: ModelInfo
    
    private enum CodingKeys: String, CodingKey {
        case modelfile, parameters, template, details
        case modelInfo = "model_info"
    }
}

public struct ModelInfo: Codable, Sendable {
    public let architecture: String
    public let fileType: Int
    public let parameterCount: Int
    public let quantizationVersion: Int 
    public let attentionHeadCount: Int
    public let attentionHeadCountKV: Int
    public let attentionLayerNormEpsilon: Double
    public let blockCount: Int
    public let contextLength: Int
    public let embeddingLength: Int
    public let feedForwardLength: Int
    public let ropeScalingType: Int?
    public let ropeDimensionCount: Int
    public let ropeFreqBase: Int
    public let vocabSize: Int

    private enum CodingKeys: String, CodingKey {
        case architecture = "general.architecture"
        case fileType = "general.file_type"
        case parameterCount = "general.parameter_count" 
        case quantizationVersion = "general.quantization_version"
        case attentionHeadCount = "llama.attention.head_count"
        case attentionHeadCountKV = "llama.attention.head_count_kv"
        case attentionLayerNormEpsilon = "llama.attention.layer_norm_rms_epsilon"
        case blockCount = "llama.block_count"
        case contextLength = "llama.context_length"
        case embeddingLength = "llama.embedding_length"
        case feedForwardLength = "llama.feed_forward_length"
        case ropeScalingType = "llama.rope.scaling_type"
        case ropeDimensionCount = "llama.rope.dimension_count"
        case ropeFreqBase = "llama.rope.freq_base"
        case vocabSize = "llama.vocab_size"
    }
}

// MARK: - Running Models Types

/// Response structure for list running models endpoint
struct RunningModelsResponse: Codable {
    let models: [RunningModelInfo]
}

/// Information about a running model
public struct RunningModelInfo: Codable, Sendable {
    /// The name of the model
    public let name: String
    /// The full model identifier
    public let model: String
    /// Size of the model in bytes
    public let size: UInt64
    /// SHA256 digest of the model
    public let digest: String
    /// Details about the model
    public let details: ModelDetails
    /// When the model will be unloaded
    public let expiresAt: Date
    /// Size of VRAM used by the model
    public let sizeVRAM: UInt64

    private enum CodingKeys: String, CodingKey {
        case name, model, size, digest, details
        case expiresAt = "expires_at"
        case sizeVRAM = "size_vram"
    }
}

// MARK: - Operation Progress Type
/// Progress information for model operations
public struct OperationProgress: Codable, Sendable {
    public init(status: String, digest: String? = nil, total: UInt64? = nil, completed: UInt64? = nil) {
        self.status = status
        self.digest = digest
        self.total = total
        self.completed = completed
    }
    
    /// The current status message
    public let status: String
    /// The current operation digest
    public let digest: String?
    /// Total size in bytes
    public let total: UInt64?
    /// Completed size in bytes 
    public let completed: UInt64?
}
