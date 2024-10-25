import Foundation
import Swollama

@main
struct SwollamaCLI {
    static func main() async throws {
        // Initialize the client with default configuration (localhost:11434)
        let client = OllamaClient()
        
        // Parse command line arguments
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard !arguments.isEmpty else {
            printUsage()
            exit(1)
        }
        
        // Process commands
        switch arguments[0] {
        case "list":
            try await listModels(client: client)
            
        case "pull":
            guard arguments.count >= 2 else {
                print("Error: Model name required for pull command")
                printUsage()
                exit(1)
            }
            try await pullModel(client: client, modelName: arguments[1])
            
        default:
            print("Unknown command: \(arguments[0])")
            printUsage()
            exit(1)
        }
    }
    
    static func printUsage() {
        print("""
        Usage:
          SwollamaCLI list                 - List all available models
          SwollamaCLI pull <model-name>    - Pull a specific model
        
        Examples:
          SwollamaCLI list
          SwollamaCLI pull llama2
        """)
    }
    
    static func listModels(client: OllamaClient) async throws {
        print("Fetching available models...")
        let models = try await client.listModels()
            .sorted { $0.name.lowercased() < $1.name.lowercased() }  // Sort alphabetically

        print("\nAvailable Models:")
        print("----------------")
        for model in models {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short

            print("- \(model.name)")
            print("  Size: \(formatSize(bytes: Int(model.size)))")
            print("  Family: \(model.details.family)")
            print("  Parameters: \(model.details.parameterSize)")
            print("  Quantization: \(model.details.quantizationLevel)")
            print("  Modified: \(dateFormatter.string(from: model.modifiedAt))\n")
        }
    }
    
    static func pullModel(client: OllamaClient, modelName: String) async throws {
        guard let model = OllamaModelName.parse(modelName) else {
            print("Error: Invalid model name format")
            return
        }
        
        print("Pulling model: \(model.fullName)")
        print("This may take a while depending on the model size and your internet connection...")
        
        let progress = try await client.pullModel(
            name: model,
            options: PullOptions()
        )
        
        for try await update in progress {
            // Clear the line and print the progress
            print("\r\u{1B}[K\(update.status)", terminator: "")
            fflush(stdout)
        }
        
        print("\nModel pull completed successfully!")
    }
    
    static func formatSize(bytes: Int) -> String {
        let gigabyte = 1024 * 1024 * 1024
        let megabyte = 1024 * 1024
        let kilobyte = 1024
        
        if bytes >= gigabyte {
            return String(format: "%.2f GB", Double(bytes) / Double(gigabyte))
        } else if bytes >= megabyte {
            return String(format: "%.2f MB", Double(bytes) / Double(megabyte))
        } else if bytes >= kilobyte {
            return String(format: "%.2f KB", Double(bytes) / Double(kilobyte))
        }
        return "\(bytes) bytes"
    }
}
