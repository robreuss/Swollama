import Foundation

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
