import Foundation
import Swollama

struct CopyModelCommand: CommandProtocol {
    private let client: OllamaProtocol

    init(client: OllamaProtocol) {
        self.client = client
    }

    func execute(with arguments: [String]) async throws {
        guard arguments.count >= 2 else {
            throw CLIError.missingArgument("Source and destination model names required")
        }

        guard let sourceModel = OllamaModelName.parse(arguments[0]) else {
            throw CLIError.invalidArgument("Invalid source model name format")
        }

        guard let destModel = OllamaModelName.parse(arguments[1]) else {
            throw CLIError.invalidArgument("Invalid destination model name format")
        }

        print("Copying model from \(sourceModel.fullName) to \(destModel.fullName)...")
        try await client.copyModel(source: sourceModel, destination: destModel)
        print("\n\u{1B}[32m✨ Model copied successfully!\u{1B}[0m")
    }
}
