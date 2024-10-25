import Foundation

/// Represents the supported model formats in Ollama.
public enum ModelFormat: String, Codable {
    case gguf
    case safetensors
    case pytorch
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = ModelFormat(rawValue: value.lowercased()) ?? .unknown
    }
}

/// Represents model families supported by Ollama.
public enum ModelFamily: String, Codable {
    case llama
    case mistral
    case vicuna
    case codellama
    case other

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = ModelFamily(rawValue: value.lowercased()) ?? .other
    }
}

/// Represents the quantization level of a model.
public enum QuantizationLevel: String, Codable {
    case Q4_0 = "Q4_0"
    case Q4_1 = "Q4_1"
    case Q5_0 = "Q5_0"
    case Q5_1 = "Q5_1"
    case Q8_0 = "Q8_0"
    case Q8_1 = "Q8_1"
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = QuantizationLevel(rawValue: value) ?? .unknown
    }
}

/// Details about a model's characteristics.
public struct ModelDetails: Codable {
    /// The parent model if this is a fine-tuned variant
    public let parentModel: String?
    /// The format of the model file
    public let format: ModelFormat
    /// The primary model family
    public let family: ModelFamily
    /// All model families this model belongs to
    public let families: [ModelFamily]?
    /// The parameter size of the model (e.g., "7B", "13B")
    public let parameterSize: String
    /// The quantization level used
    public let quantizationLevel: QuantizationLevel

    private enum CodingKeys: String, CodingKey {
        case parentModel = "parent_model"
        case format
        case family
        case families
        case parameterSize = "parameter_size"
        case quantizationLevel = "quantization_level"
    }
}
