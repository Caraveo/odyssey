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
        try data.write(to: url)
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
        savePanel.nameFieldStringValue = "Untitled Book"
        savePanel.canCreateDirectories = true
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
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

