import Foundation

/// A protocol defining the core functionality of an Ollama client.
///
/// This protocol provides a comprehensive interface for interacting with the Ollama API,
/// including model management, text generation, and embeddings generation.
public protocol OllamaProtocol: Sendable {
    /// The base URL of the Ollama API server
    var baseURL: URL { get }
    
    /// The configuration used for API requests
    var configuration: OllamaConfiguration { get }
    
    /// Lists all models that are available locally.
    /// - Returns: An array of model information.
    /// - Throws: An `OllamaError` if the request fails.
    func listModels() async throws -> [ModelInfo]
    
    /// Shows detailed information about a specific model.
    /// - Parameter name: The name of the model to show information for.
    /// - Returns: Detailed information about the model.
    /// - Throws: An `OllamaError` if the request fails.
    func showModel(name: OllamaModelName) async throws -> ModelInformation
    
    /// Pulls a model from the Ollama library.
    /// - Parameters:
    ///   - name: The name of the model to pull.
    ///   - options: Optional parameters for the pull operation.
    /// - Returns: An async sequence of progress updates.
    /// - Throws: An `OllamaError` if the request fails.
    func pullModel(
        name: OllamaModelName,
        options: PullOptions
    ) async throws -> AsyncThrowingStream<OperationProgress, Error>

    /// Pushes a model to the Ollama library.
    /// - Parameters:
    ///   - name: The name of the model to push.
    ///   - options: Optional parameters for the push operation.
    /// - Returns: An async sequence of progress updates.
    /// - Throws: An `OllamaError` if the request fails.
    func pushModel(
        name: OllamaModelName,
        options: PushOptions
    ) async throws -> AsyncThrowingStream<OperationProgress, Error>
    
    /// Copies a model.
    /// - Parameters:
    ///   - source: The source model name.
    ///   - destination: The destination model name.
    /// - Throws: An `OllamaError` if the request fails.
    func copyModel(source: OllamaModelName, destination: OllamaModelName) async throws
    
    /// Deletes a model.
    /// - Parameter name: The name of the model to delete.
    /// - Throws: An `OllamaError` if the request fails.
    func deleteModel(name: OllamaModelName) async throws
    
    /// Lists currently running models.
    /// - Returns: An array of running model information.
    /// - Throws: An `OllamaError` if the request fails.
    func listRunningModels() async throws -> [RunningModelInfo]
}
