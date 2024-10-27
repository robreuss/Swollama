import Foundation
import Swollama

struct PullModelCommand: CommandProtocol {
    private let client: OllamaProtocol
    private let progressTracker: ProgressTracker

    init(
        client: OllamaProtocol,
        progressTracker: ProgressTracker = DefaultProgressTracker()
    ) {
        self.client = client
        self.progressTracker = progressTracker
    }

    func execute(with arguments: [String]) async throws {
        guard !arguments.isEmpty else {
            throw CLIError.missingArgument("Model name required")
        }

        guard let model = OllamaModelName.parse(arguments[0]) else {
            throw CLIError.invalidArgument("Invalid model name format")
        }

        print("Pulling model: \(model.fullName)")
        print("This may take a while depending on the model size and your internet connection...")

        let progress = try await client.pullModel(
            name: model,
            options: PullOptions()
        )

        try await progressTracker.track(progress)
        print("\n\u{1B}[32m✨ Model pull completed successfully!\u{1B}[0m")
    }
}
