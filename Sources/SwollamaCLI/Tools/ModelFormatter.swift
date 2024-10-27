import Foundation
import Swollama

/// Protocol defining the interface for formatting model information.
protocol ModelFormatter {
    /// Formats a model entry into a human-readable string.
    /// - Parameter model: The model entry to format.
    /// - Returns: A formatted string representation of the model.
    func format(_ model: ModelListEntry) -> String
}

/// Default implementation of ModelFormatter that provides a standardized format.
struct DefaultModelFormatter: ModelFormatter {
    /// Date formatter configured for displaying model modification times.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    /// Formats a model entry into a multi-line string containing key model information.
    /// - Parameter model: The model entry to format.
    /// - Returns: A formatted string with model details including size, family, parameters, and modification date.
    func format(_ model: ModelListEntry) -> String {
        """
        - \(model.name)
          Size: \(FileSize.format(bytes: Int(model.size)))
          Family: \(model.details.family)
          Parameters: \(model.details.parameterSize)
          Quantization: \(model.details.quantizationLevel)
          Modified: \(dateFormatter.string(from: model.modifiedAt))
        
        """
    }
}

/// Utility struct for formatting file sizes into human-readable strings.
struct FileSize {
    /// Formats a byte count into a human-readable string with appropriate units.
    /// - Parameter bytes: The number of bytes to format.
    /// - Returns: A formatted string with the appropriate size unit (GB, MB, KB, or bytes).
    static func format(bytes: Int) -> String {
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
