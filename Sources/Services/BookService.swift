import Foundation
import AppKit
import UniformTypeIdentifiers

class BookService {
    static let shared = BookService()
    
    private init() {}
    
    func saveBook(_ book: Book, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(book)
        
        // Create directory if it doesn't exist
        let fileManager = FileManager.default
        let directory = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        // Write atomically to prevent corruption
        try data.write(to: url, options: .atomic)
    }
    
    func loadBook(from url: URL) throws -> Book {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(Book.self, from: data)
    }
    
    func showSavePanel(title: String = "Save Book") -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = title
        savePanel.allowedContentTypes = [.book]
        savePanel.nameFieldStringValue = "Untitled Book.book"
        savePanel.canCreateDirectories = true
        savePanel.allowsOtherFileTypes = false
        
        let response = savePanel.runModal()
        guard response == .OK, var url = savePanel.url else { return nil }
        
        // Ensure .book extension is present
        if url.pathExtension != "book" {
            url = url.deletingPathExtension().appendingPathExtension("book")
        }
        
        return url
    }
    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.title = "Open Book"
        openPanel.allowedContentTypes = [.book]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}

extension UTType {
    static var book: UTType {
        if let type = UTType(filenameExtension: "book") {
            return type
        }
        // Fallback: create a dynamic type
        return UTType(exportedAs: "com.odyssey.book", conformingTo: .data)
    }
}

