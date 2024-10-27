import Foundation

protocol CommandProtocol {
    func execute(with arguments: [String]) async throws
}
