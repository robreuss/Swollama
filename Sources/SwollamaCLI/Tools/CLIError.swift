import Foundation

enum CLIError: LocalizedError {
    case unknownCommand(String)
    case missingArgument(String)
    case invalidArgument(String)

    var errorDescription: String? {
        switch self {
        case .unknownCommand(let cmd):
            return "Unknown command: \(cmd)"
        case .missingArgument(let msg):
            return "Missing argument: \(msg)"
        case .invalidArgument(let msg):
            return "Invalid argument: \(msg)"
        }
    }
}

