import Foundation
import CryptoKit

struct RecoverySnapshot: Codable, Identifiable {
    let id: String
    let sessionID: UUID
    let sourceBookURL: URL?
    let capturedAt: Date
    let book: Book
}

final class RecoveryService {
    static let shared = RecoveryService()
    
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
    }
    
    func saveSnapshot(book: Book, sourceBookURL: URL?, sessionID: UUID) throws -> RecoverySnapshot {
        let snapshot = RecoverySnapshot(
            id: snapshotID(for: sourceBookURL, sessionID: sessionID),
            sessionID: sessionID,
            sourceBookURL: sourceBookURL,
            capturedAt: Date(),
            book: book
        )
        
        let data = try encoder.encode(snapshot)
        let url = try snapshotURL(for: sourceBookURL, sessionID: sessionID)
        try ensureRecoveryDirectoryExists()
        try data.write(to: url, options: .atomic)
        return snapshot
    }
    
    func loadSnapshot(for sourceBookURL: URL) throws -> RecoverySnapshot? {
        let url = try snapshotURL(for: sourceBookURL, sessionID: UUID())
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try? decoder.decode(RecoverySnapshot.self, from: data)
    }
    
    func mostRecentUntitledSnapshot() throws -> RecoverySnapshot? {
        try allSnapshots()
            .filter { $0.sourceBookURL == nil }
            .max { $0.capturedAt < $1.capturedAt }
    }
    
    func deleteSnapshot(_ snapshot: RecoverySnapshot) throws {
        try deleteSnapshot(for: snapshot.sourceBookURL, sessionID: snapshot.sessionID)
    }
    
    func deleteSnapshot(for sourceBookURL: URL?, sessionID: UUID) throws {
        let url = try snapshotURL(for: sourceBookURL, sessionID: sessionID)
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }
    
    private func allSnapshots() throws -> [RecoverySnapshot] {
        let directory = try recoveryDirectory()
        guard fileManager.fileExists(atPath: directory.path) else { return [] }
        
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        return urls
            .filter { $0.pathExtension == "recovery" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(RecoverySnapshot.self, from: data)
            }
    }
    
    private func snapshotURL(for sourceBookURL: URL?, sessionID: UUID) throws -> URL {
        try recoveryDirectory()
            .appendingPathComponent(snapshotID(for: sourceBookURL, sessionID: sessionID))
            .appendingPathExtension("recovery")
    }
    
    private func snapshotID(for sourceBookURL: URL?, sessionID: UUID) -> String {
        if let sourceBookURL {
            let path = sourceBookURL.standardizedFileURL.path
            let digest = SHA256.hash(data: Data(path.utf8))
            let hex = digest.compactMap { String(format: "%02x", $0) }.joined()
            return "file-\(hex)"
        }
        
        return "draft-\(sessionID.uuidString.lowercased())"
    }
    
    private func ensureRecoveryDirectoryExists() throws {
        let directory = try recoveryDirectory()
        guard !fileManager.fileExists(atPath: directory.path) else { return }
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    
    private func recoveryDirectory() throws -> URL {
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw NSError(
                domain: "RecoveryService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to locate Application Support directory."]
            )
        }
        
        return appSupportDirectory
            .appendingPathComponent("Odyssey", isDirectory: true)
            .appendingPathComponent("Recovery", isDirectory: true)
    }
}
