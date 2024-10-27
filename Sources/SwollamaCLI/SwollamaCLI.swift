import Foundation
import Swollama

@main
struct SwollamaCLI {
    private static var commands: [String: CommandProtocol] = {
        let client = OllamaClient()
        return [
            "list": ListModelsCommand(client: client),
            "pull": PullModelCommand(client: client),
            "show": ShowModelCommand(client: client),
            "copy": CopyModelCommand(client: client),
            "delete": DeleteModelCommand(client: client),
            "ps": ListRunningModelsCommand(client: client),
            "chat": ChatCommand(client: client),
            "generate": GenerateCommand(client: client),
        ]
    }()

    static func main() async throws {
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard !arguments.isEmpty else {
            printUsage()
            exit(1)
        }

        do {
            let commandName = arguments[0]
            guard let command = commands[commandName] else {
                throw CLIError.unknownCommand(commandName)
            }
            try await command.execute(with: Array(arguments.dropFirst()))
        } catch {
            handleError(error)
        }
    }

    private static func handleError(_ error: Error) {
        print("\u{1B}[31mError: \(error.localizedDescription)\u{1B}[0m")
        printUsage()
        exit(1)
    }

    private static func printUsage() {
        print(
            """
            Usage:
              SwollamaCLI list                 - List all available models
              SwollamaCLI pull <model-name>    - Pull a specific model
              SwollamaCLI show <model-name>    - Show detailed information about a model
              SwollamaCLI copy <src> <dest>    - Copy a model to a new name
              SwollamaCLI delete <model-name>  - Delete a specific model
              SwollamaCLI ps                   - List currently running models
              SwollamaCLI generate <model-name>  - Start an interactive text generation session
              SwollamaCLI chat <model-name>    - Start an interactive chat session

            Examples:
              SwollamaCLI list
              SwollamaCLI pull llama2
              SwollamaCLI show llama2
              SwollamaCLI copy llama2 my-llama2
              SwollamaCLI delete my-llama2
              SwollamaCLI ps
              SwollamaCLI chat llama2
            """
        )
    }
}
