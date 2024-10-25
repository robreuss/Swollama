import Foundation

extension OllamaClient {
    public func listModels() async throws -> [ModelInfo] {
        let data = try await makeRequest(endpoint: "tags")
        let response = try decode(data, as: ModelsResponse.self)
        return response.models
    }

    public func showModel(name: OllamaModelName) async throws -> ModelInformation {
        let request = ShowModelRequest(name: name.fullName)
        let data = try await makeRequest(
            endpoint: "show",
            method: "POST",
            body: try encode(request)
        )
        return try decode(data, as: ModelInformation.self)
    }

    public func pullModel(
        name: OllamaModelName,
        options: PullOptions
    ) async throws -> AsyncThrowingStream<OperationProgress, Error> {
        let request = PullModelRequest(
            name: name.fullName,
            insecure: options.allowInsecure,
            stream: true
        )

        return streamRequest(
            endpoint: "pull",
            method: "POST",
            body: try encode(request),
            as: OperationProgress.self
        )
    }

    public func pushModel(
        name: OllamaModelName,
        options: PushOptions
    ) async throws -> AsyncThrowingStream<OperationProgress, Error> {
        // Validate model name has namespace
        guard name.namespace != nil else {
            throw OllamaError.invalidParameters("Model name must include namespace for pushing")
        }

        let request = PushModelRequest(
            name: name.fullName,
            insecure: options.allowInsecure,
            stream: true
        )

        return streamRequest(
            endpoint: "push",
            method: "POST",
            body: try encode(request),
            as: OperationProgress.self
        )
    }

    public func copyModel(
        source: OllamaModelName,
        destination: OllamaModelName
    ) async throws {
        let request = CopyModelRequest(
            source: source.fullName,
            destination: destination.fullName
        )

        _ = try await makeRequest(
            endpoint: "copy",
            method: "POST",
            body: try encode(request)
        )
    }

    public func deleteModel(name: OllamaModelName) async throws {
        let request = DeleteModelRequest(name: name.fullName)
        _ = try await makeRequest(
            endpoint: "delete",
            method: "DELETE",
            body: try encode(request)
        )
    }

    public func listRunningModels() async throws -> [RunningModelInfo] {
        let data = try await makeRequest(endpoint: "ps")
        let response = try decode(data, as: RunningModelsResponse.self)
        return response.models
    }
}

// Supporting Types
private struct ModelsResponse: Codable {
    let models: [ModelInfo]
}

private struct RunningModelsResponse: Codable {
    let models: [RunningModelInfo]
}

private struct ShowModelRequest: Codable {
    let name: String
}

private struct PullModelRequest: Codable {
    let name: String
    let insecure: Bool
    let stream: Bool
}

private struct PushModelRequest: Codable {
    let name: String
    let insecure: Bool
    let stream: Bool
}

private struct CopyModelRequest: Codable {
    let source: String
    let destination: String
}

private struct DeleteModelRequest: Codable {
    let name: String
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

/// Progress information for model operations
public struct OperationProgress: Codable, Sendable {
    /// The current status message
    public let status: String
    /// The current operation digest
    public let digest: String?
    /// Total size in bytes
    public let total: UInt64?
    /// Completed size in bytes
    public let completed: UInt64?
}
/// Options for pulling models
public struct PullOptions {
    /// Whether to allow insecure connections
    public let allowInsecure: Bool

    public init(allowInsecure: Bool = false) {
        self.allowInsecure = allowInsecure
    }
}

/// Options for pushing models
public struct PushOptions {
    /// Whether to allow insecure connections
    public let allowInsecure: Bool

    public init(allowInsecure: Bool = false) {
        self.allowInsecure = allowInsecure
    }
}
