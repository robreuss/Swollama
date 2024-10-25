import Foundation
import Swollama

protocol ProgressTracker {
    func track(_ progress: AsyncThrowingStream<OperationProgress, Error>) async throws
}

struct DefaultProgressTracker: ProgressTracker {
    private let terminalHelper: TerminalHelper
    private let speedCalculator: SpeedCalculator

    init(
        terminalHelper: TerminalHelper = DefaultTerminalHelper(),
        speedCalculator: SpeedCalculator = MovingAverageSpeedCalculator()
    ) {
        self.terminalHelper = terminalHelper
        self.speedCalculator = speedCalculator
    }

    func track(_ progress: AsyncThrowingStream<OperationProgress, Error>) async throws {
        let barWidth = min(terminalHelper.terminalWidth - 65, 50)

        for try await update in progress {
            guard let completed = update.completed,
                  let total = update.total,
                  total > 0 else { continue }

            let percentage = (Double(completed) / Double(total)) * 100.0
            let isCompleted = completed == total

            let speed = isCompleted ? 0.0 : speedCalculator.calculateSpeed(bytes: completed)
            let eta = isCompleted ? 0 : speedCalculator.estimateTimeRemaining(completed: completed, total: total)

            let progressBar = ProgressBarFormatter.create(
                percentage: percentage,
                width: barWidth,
                status: update.status,
                completed: completed,
                total: total,
                speed: speed,
                eta: eta,
                isCompleted: isCompleted
            )

            print("\r\u{1B}[K\(progressBar)", terminator: "")
            fflush(stdout)
        }
    }
}

// MARK: - Utilities
struct ProgressBarFormatter {
    static func create(
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
        let sizeInfo = "[\(FileSize.format(bytes: Int(completed)))/\(FileSize.format(bytes: Int(total)))]"

        let additionalInfo = if isCompleted {
            "✓ Complete"
        } else if speed > 0.1 {
            "\u{1B}[33m\(formatSpeed(bytesPerSecond: speed))\u{1B}[0m \u{1B}[35m\(formatETA(seconds: eta))\u{1B}[0m"
        } else {
            "initializing..."
        }

        return "[\(filled)\(empty)] \u{1B}[36m\(percentStr)\u{1B}[0m \(sizeInfo) \(additionalInfo)"
    }

    private static func formatSpeed(bytesPerSecond: Double) -> String {
        let mbps = bytesPerSecond / 1_048_576
        return String(format: "%.1f MB/s", mbps)
    }

    private static func formatETA(seconds: Int) -> String {
        if seconds == 0 { return "calculating..." }

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
}

