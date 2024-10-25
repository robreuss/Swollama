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

        let terminalWidth = getTerminalWidth() ?? 50
        let barWidth = min(terminalWidth - 65, 50)

        // Speed calculation with moving average (previous implementation)
        var speedReadings: [(timestamp: Date, bytes: UInt64)] = []
        let speedWindowSeconds: TimeInterval = 3.0

        let progress = try await client.pullModel(
            name: model,
            options: PullOptions()
        )

        var isCompleted = false
        for try await update in progress {
            if let completed = update.completed, let total = update.total, total > 0 {
                let now = Date()
                let percentage = (Double(completed) / Double(total)) * 100.0
                isCompleted = completed == total

                // Update speed readings (only if not completed)
                if !isCompleted {
                    speedReadings.append((now, completed))
                    speedReadings = speedReadings.filter {
                        now.timeIntervalSince($0.timestamp) <= speedWindowSeconds
                    }
                }

                // Calculate speed and ETA (only if not completed)
                let (speed, eta): (Double, Int) = {
                    if isCompleted {
                        return (0.0, 0)
                    }

                    if speedReadings.count >= 2 {
                        let oldest = speedReadings.first!
                        let timeSpan = now.timeIntervalSince(oldest.timestamp)
                        let byteSpan = Double(completed - oldest.bytes)
                        let currentSpeed = timeSpan > 0 ? byteSpan / timeSpan : 0
                        let remainingBytes = Double(total - completed)
                        let currentEta = currentSpeed > 0 ? Int(remainingBytes / currentSpeed) : 0
                        return (currentSpeed, currentEta)
                    }

                    return (0.0, 0)
                }()

                // Create progress bar
                let progressBar = createProgressBar(
                    percentage: percentage,
                    width: barWidth,
                    status: update.status,
                    completed: completed,
                    total: total,
                    speed: speed,
                    eta: eta,
                    isCompleted: isCompleted
                )

                // Clear line and print progress
                print("\r\u{1B}[K\(progressBar)", terminator: "")
                fflush(stdout)
            }
        }

        print("\n\u{1B}[32m✨ Model pull completed successfully!\u{1B}[0m")
    }

    // Helper function to create a progress bar
    private static func createProgressBar(
        percentage: Double,
        width: Int,
        status: String,
        completed: UInt64,
        total: UInt64,
        speed: Double,
        eta: Int,
        isCompleted: Bool
    ) -> String {
        let filledWidth = Int(Double(width) * percentage / 100.0)
        let emptyWidth = width - filledWidth

        let filled = "\u{1B}[32m" + String(repeating: "█", count: filledWidth) + "\u{1B}[0m"
        let empty = String(repeating: "░", count: emptyWidth)

        let percentStr = String(format: "%6.2f%%", percentage)
        let sizeInfo = "[\(formatSize(bytes: Int(completed)))/\(formatSize(bytes: Int(total)))]"

        // Only show speed and ETA if not completed and speed is meaningful
        let additionalInfo = if isCompleted {
            "✓ Complete"
        } else if speed > 0.1 {
            "\u{1B}[33m\(formatSpeed(bytesPerSecond: speed))\u{1B}[0m \u{1B}[35m\(formatETA(seconds: eta))\u{1B}[0m"
        } else {
            "initializing..."
        }

        return "[\(filled)\(empty)] \u{1B}[36m\(percentStr)\u{1B}[0m \(sizeInfo) \(additionalInfo)"
    }

    // Helper function to format speed (rounded to 1 decimal place for stability)
    private static func formatSpeed(bytesPerSecond: Double) -> String {
        let mbps = bytesPerSecond / 1_048_576 // Convert to MB/s
        return String(format: "%.1f MB/s", mbps)
    }

    // Helper function to format ETA (now with more stable rounding)
    private static func formatETA(seconds: Int) -> String {
        if seconds == 0 {
            return "calculating..."
        }

        // Round up to nearest 5 seconds for more stable display
        let roundedSeconds = ((seconds + 4) / 5) * 5

        let hours = roundedSeconds / 3600
        let minutes = (roundedSeconds % 3600) / 60
        let remainingSeconds = roundedSeconds % 60

        if hours > 0 {
            return String(format: "ETA: %dh%02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "ETA: %dm%02ds", minutes, remainingSeconds)
        } else {
            return String(format: "ETA: %ds", remainingSeconds)
        }
    }

    // Helper function to get terminal width
    private static func getTerminalWidth() -> Int? {
        var w = winsize()
        guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 else {
            return nil
        }
        return Int(w.ws_col)
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
