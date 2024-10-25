import Foundation
import Swollama

protocol Command {
    func execute(with arguments: [String]) async throws
}

struct ListModelsCommand: Command {
    private let client: OllamaProtocol
    private let formatter: ModelFormatter

    init(client: OllamaProtocol, formatter: ModelFormatter = DefaultModelFormatter()) {
        self.client = client
        self.formatter = formatter
    }

    func execute(with arguments: [String]) async throws {
        print("Fetching available models...")
        let models = try await client.listModels()
            .sorted { $0.name.lowercased() < $1.name.lowercased() }

        print("\nAvailable Models:")
        print("----------------")
        for model in models {
            print(formatter.format(model))
        }
    }
}

struct PullModelCommand: Command {
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
