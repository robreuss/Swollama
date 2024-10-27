import Foundation

/// Detailed model information returned from show endpoint
public struct ModelInformation: Codable, Sendable {
    /// The Modelfile content
    public let modelfile: String
    /// Model parameters (optional)
    public let parameters: String?
    /// The template used for prompts
    public let template: String
    /// Details about the model
    public let details: ModelDetails

    private enum CodingKeys: String, CodingKey {
        case modelfile, parameters, template, details
    }
}
