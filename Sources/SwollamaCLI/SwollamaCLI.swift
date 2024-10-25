import Foundation
import Swollama

@main
struct SwollamaCLI {
    private static var commands: [String: Command] = {
        let client = OllamaClient()
        return [
            "list": ListModelsCommand(client: client),
            "pull": PullModelCommand(client: client)
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
        print("Error: \(error.localizedDescription)")
        printUsage()
        exit(1)
    }

    private static func printUsage() {
        print("""
        Usage:
          SwollamaCLI list                 - List all available models
          SwollamaCLI pull <model-name>    - Pull a specific model
        
        Examples:
          SwollamaCLI list
          SwollamaCLI pull llama2
        """)
    }
}

