import Foundation

/// Progress information for model operations
public struct OperationProgress: Codable, Sendable {
    public init(status: String, digest: String? = nil, total: UInt64? = nil, completed: UInt64? = nil) {
        self.status = status
        self.digest = digest
        self.total = total
        self.completed = completed
    }

    /// The current status message
    public let status: String
    /// The current operation digest
    public let digest: String?
    /// Total size in bytes
    public let total: UInt64?
    /// Completed size in bytes
    public let completed: UInt64?
}
