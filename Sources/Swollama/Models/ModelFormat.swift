import Foundation

/// Represents the supported model formats in Ollama.
public enum ModelFormat: String, Codable {
    /// GGUF (GGML Universal Format) model format
    case gguf

    /// SafeTensors model format, designed for safe and efficient serialization
    case safetensors

    /// PyTorch model format
    case pytorch

    /// Used when the model format is not recognized
    case unknown

    /// Creates a new ModelFormat from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError` if decoding fails.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = ModelFormat(rawValue: value.lowercased()) ?? .unknown
    }
}
