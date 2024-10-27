import Foundation

/// Represents the quantization level of a model.
public enum QuantizationLevel: String, Codable {
    /// 4-bit quantization, version 0
    case Q4_0 = "Q4_0"

    /// 4-bit quantization, version 1
    case Q4_1 = "Q4_1"

    /// 5-bit quantization, version 0
    case Q5_0 = "Q5_0"

    /// 5-bit quantization, version 1
    case Q5_1 = "Q5_1"

    /// 8-bit quantization, version 0
    case Q8_0 = "Q8_0"

    /// 8-bit quantization, version 1
    case Q8_1 = "Q8_1"

    /// Used when the quantization level is not recognized
    case unknown

    /// Creates a new QuantizationLevel from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError` if decoding fails.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = QuantizationLevel(rawValue: value) ?? .unknown
    }
}
