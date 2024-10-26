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

struct ShowModelCommand: Command {
    private let client: OllamaProtocol

    init(client: OllamaProtocol) {
        self.client = client
    }

    func execute(with arguments: [String]) async throws {
        guard !arguments.isEmpty else {
            throw CLIError.missingArgument("Model name required")
        }
        guard let model = OllamaModelName.parse(arguments[0]) else {
            throw CLIError.invalidArgument("Invalid model name format")
        }

        print("Fetching details for model: \(model.fullName)...")
        let info = try await client.showModel(name: model)

        print("\nModel Details:")
        print("--------------")
        print("Properties:")
        print("  Format: \(info.details.format)")
        print("  Family: \(info.details.family)")
        if let families = info.details.families {
            print("  All Families: \(families.joined(separator: ", "))")
        }
        print("  Parameter Size: \(info.details.parameterSize)")
        print("  Quantization: \(info.details.quantizationLevel)")
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }
}

struct CopyModelCommand: Command {
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

struct DeleteModelCommand: Command {
    private let client: OllamaProtocol

    init(client: OllamaProtocol) {
        self.client = client
    }

    func execute(with arguments: [String]) async throws {
        guard !arguments.isEmpty else {
            throw CLIError.missingArgument("Model name required")
        }

        guard let model = OllamaModelName.parse(arguments[0]) else {
            throw CLIError.invalidArgument("Invalid model name format")
        }

        print("Are you sure you want to delete model: \(model.fullName)? (y/N)")
        guard let response = readLine()?.lowercased(),
              response == "y" || response == "yes" else {
            print("Operation cancelled.")
            return
        }

        print("Deleting model...")
        try await client.deleteModel(name: model)
        print("\n\u{1B}[32m✨ Model deleted successfully!\u{1B}[0m")
    }
}

struct ListRunningModelsCommand: Command {
    private let client: OllamaProtocol

    init(client: OllamaProtocol) {
        self.client = client
    }

    func execute(with arguments: [String]) async throws {
        print("Fetching running models...")
        let models = try await client.listRunningModels()

        if models.isEmpty {
            print("\nNo models currently running.")
            return
        }

        print("\nRunning Models:")
        print("--------------")
        for model in models {
            print("- Model: \(model.name)")
            print("  Full ID: \(model.model)")
            print("  Size: \(formatBytes(model.size))")
            print("  VRAM Usage: \(formatBytes(model.sizeVRAM))")
            print("  Expires: \(formatDate(model.expiresAt))")
            print("  Details:")
            print("    Family: \(model.details.family)")
            print("    Parameter Size: \(model.details.parameterSize)")
            print("    Quantization: \(model.details.quantizationLevel)")
            print("    Format: \(model.details.format)")
            print("")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeTime = formatter.localizedString(for: date, relativeTo: Date())

        let absoluteFormatter = DateFormatter()
        absoluteFormatter.dateStyle = .medium
        absoluteFormatter.timeStyle = .medium
        let absoluteTime = absoluteFormatter.string(from: date)

        return "\(relativeTime) (\(absoluteTime))"
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0

        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }

        return String(format: "%.2f %@", value, units[unitIndex])
    }
}
