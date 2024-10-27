import Foundation
import Swollama

protocol ProgressTracker {
    func track(_ progress: AsyncThrowingStream<OperationProgress, Error>) async throws
}

struct DownloadPart: Identifiable {
    let id: String // digest
    let total: UInt64
    var completed: UInt64
    let status: String
    let speedCalculator: SpeedCalculator

    var progress: Double {
        Double(completed) / Double(total) * 100.0
    }

    var isComplete: Bool {
        completed == total
    }
}

struct DefaultProgressTracker: ProgressTracker {
    private let terminalHelper: TerminalHelper

    init(terminalHelper: TerminalHelper = DefaultTerminalHelper()) {
        self.terminalHelper = terminalHelper
    }

    func track(_ progress: AsyncThrowingStream<OperationProgress, Error>) async throws {
        let barWidth = min(terminalHelper.terminalWidth - 65, 50)
        var parts: [String: DownloadPart] = [:]
        var updates: [OperationProgress] = []

        // Initial discovery phase with timeout
        let discoveryTimeout: TimeInterval = 0.5 // Wait up to 0.5 seconds for initial parts
        let discoveryStart = Date()

        // Buffer initial updates to discover parts
        for try await update in progress {
            updates.append(update)

            guard let digest = update.digest,
                  let total = update.total else { continue }

            if parts[digest] == nil {
                parts[digest] = DownloadPart(
                    id: digest,
                    total: total,
                    completed: update.completed ?? 0,
                    status: update.status,
                    speedCalculator: MovingAverageSpeedCalculator()
                )

                // Draw the new part's progress bar
                drawPart(parts[digest]!, barWidth: barWidth)
            }

            // Break after timeout
            if Date().timeIntervalSince(discoveryStart) > discoveryTimeout {
                break
            }
        }

        // Process buffered updates
        for update in updates {
            processUpdate(update, parts: &parts, barWidth: barWidth)
        }

        // Continue with remaining updates
        for try await update in progress {
            processUpdate(update, parts: &parts, barWidth: barWidth)
        }
    }

    private func processUpdate(_ update: OperationProgress, parts: inout [String: DownloadPart], barWidth: Int) {
        guard let digest = update.digest,
              let completed = update.completed else { return }

        if var part = parts[digest] {
            part.completed = completed
            parts[digest] = part

            // Update this part's progress bar
            updatePartProgress(part, barWidth: barWidth)
        } else {
            // New part discovered during download
            guard let total = update.total else { return }
            let newPart = DownloadPart(
                id: digest,
                total: total,
                completed: completed,
                status: update.status,
                speedCalculator: MovingAverageSpeedCalculator()
            )
            parts[digest] = newPart
            drawPart(newPart, barWidth: barWidth)
        }
    }

    private func drawPart(_ part: DownloadPart, barWidth: Int) {
        let speed = part.speedCalculator.calculateSpeed(bytes: part.completed)
        let eta = part.speedCalculator.estimateTimeRemaining(
            completed: part.completed,
            total: part.total
        )

        let progressBar = ProgressBarFormatter.create(
            percentage: part.progress,
            width: barWidth,
            status: part.status,
            completed: part.completed,
            total: part.total,
            speed: speed,
            eta: eta,
            isCompleted: part.isComplete,
            digest: part.id.prefix(8)
        )

        print(progressBar)
    }

    private func updatePartProgress(_ part: DownloadPart, barWidth: Int) {
        let speed = part.speedCalculator.calculateSpeed(bytes: part.completed)
        let eta = part.speedCalculator.estimateTimeRemaining(
            completed: part.completed,
            total: part.total
        )

        let progressBar = ProgressBarFormatter.create(
            percentage: part.progress,
            width: barWidth,
            status: part.status,
            completed: part.completed,
            total: part.total,
            speed: speed,
            eta: eta,
            isCompleted: part.isComplete,
            digest: part.id.prefix(8)
        )

        // Move cursor up one line and clear it
        print("\u{1B}[1A\u{1B}[K\(progressBar)")
    }
}

struct ProgressBarFormatter {
    static func create(
        percentage: Double,
        width: Int,
        status: String,
        completed: UInt64,
        total: UInt64,
        speed: Double,
        eta: Int,
        isCompleted: Bool,
        digest: Substring
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

        return "[\(filled)\(empty)] \u{1B}[36m\(percentStr)\u{1B}[0m \(sizeInfo) \(additionalInfo) [\(digest)]"
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
