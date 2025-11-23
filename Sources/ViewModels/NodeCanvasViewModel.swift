import Foundation
import SwiftUI

@MainActor
class NodeCanvasViewModel: ObservableObject {
    @Published var nodes: [Node] = []
    @Published var selectedNodeId: UUID?
    @Published var draggingNodeId: UUID?
    @Published var dragOffset: CGSize = .zero
    @Published var linkingFromNodeId: UUID?
    @Published var isLinkingMode: Bool = false
    @Published var currentBookURL: URL?
    @Published var bookTitle: String = "Untitled Book"
    @Published var hasUnsavedChanges: Bool = false
    @Published var isAutoSaving: Bool = false
    
    private var autoSaveTimer: Timer?
    private var autoSaveTask: Task<Void, Never>?
    private let autoSaveDelay: TimeInterval = 3.0 // Auto-save 3 seconds after last change
    
    var selectedNode: Node? {
        guard let selectedNodeId = selectedNodeId else { return nil }
        return nodes.first { $0.id == selectedNodeId }
    }
    
    var connections: [NodeConnection] {
        var connections: [NodeConnection] = []
        for node in nodes {
            for linkedId in node.linkedNodeIds {
                connections.append(NodeConnection(from: node.id, to: linkedId))
            }
        }
        return connections
    }
    
    func addNode(title: String, category: NodeCategory, at position: CGPoint) {
        let node = Node(title: title, category: category, position: position)
        nodes.append(node)
        markAsChanged()
    }
    
    func deleteNode(_ nodeId: UUID) {
        nodes.removeAll { $0.id == nodeId }
        // Remove links to this node from other nodes
        for i in nodes.indices {
            nodes[i].linkedNodeIds.remove(nodeId)
        }
        if selectedNodeId == nodeId {
            selectedNodeId = nil
        }
        markAsChanged()
    }
    
    func updateNode(_ nodeId: UUID, title: String? = nil, content: String? = nil, aiResults: String? = nil) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        if let title = title {
            nodes[index].title = title
            markAsChanged()
        }
        if let content = content {
            nodes[index].content = content
            markAsChanged()
        }
        if let aiResults = aiResults {
            nodes[index].aiResults = aiResults
            markAsChanged()
        }
    }
    
    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
        if !isLinkingMode {
            linkingFromNodeId = nil
        }
    }
    
    func toggleLinkingMode() {
        isLinkingMode.toggle()
        if !isLinkingMode {
            linkingFromNodeId = nil
        }
    }
    
    func handleNodeClick(_ nodeId: UUID) {
        if isLinkingMode {
            if let fromId = linkingFromNodeId {
                // Complete linking
                if fromId != nodeId {
                    guard let fromIndex = nodes.firstIndex(where: { $0.id == fromId }) else {
                        linkingFromNodeId = nil
                        return
                    }
                    nodes[fromIndex].link(to: nodeId)
                    markAsChanged()
                }
                linkingFromNodeId = nil
            } else {
                // Start linking
                linkingFromNodeId = nodeId
            }
        } else {
            // Normal selection
            selectNode(nodeId)
        }
    }
    
    func removeLink(from: UUID, to: UUID) {
        guard let fromIndex = nodes.firstIndex(where: { $0.id == from }) else { return }
        nodes[fromIndex].unlink(from: to)
        markAsChanged()
    }
    
    func getContextForPrompt() -> String {
        guard let selectedNode = selectedNode else {
            return "No node selected. Select a node to generate context-aware prompts."
        }
        
        var context = "Selected Node: \(selectedNode.title) (\(selectedNode.category.rawValue))\n"
        context += "Content: \(selectedNode.content.isEmpty ? "No content yet" : selectedNode.content)\n\n"
        
        if !selectedNode.linkedNodeIds.isEmpty {
            context += "Linked Nodes:\n"
            for linkedId in selectedNode.linkedNodeIds {
                if let linkedNode = nodes.first(where: { $0.id == linkedId }) {
                    context += "- \(linkedNode.title) (\(linkedNode.category.rawValue)): \(linkedNode.content.isEmpty ? "No content" : linkedNode.content)\n"
                }
            }
        }
        
        return context
    }
    
    func getRelatedNodes(for nodeId: UUID) -> [Node] {
        guard let node = nodes.first(where: { $0.id == nodeId }) else { return [] }
        return nodes.filter { node.linkedNodeIds.contains($0.id) }
    }
    
    func loadBook(_ book: Book) {
        nodes = book.nodes
        bookTitle = book.title
        selectedNodeId = nil
        hasUnsavedChanges = false
    }
    
    func createBook() -> Book {
        return Book(title: bookTitle, nodes: nodes)
    }
    
    func newBook() {
        nodes = []
        selectedNodeId = nil
        linkingFromNodeId = nil
        isLinkingMode = false
        currentBookURL = nil
        bookTitle = "Untitled Book"
        hasUnsavedChanges = false
    }
    
    func markAsChanged() {
        hasUnsavedChanges = true
        scheduleAutoSave()
    }
    
    private func scheduleAutoSave() {
        // Cancel existing timer
        autoSaveTimer?.invalidate()
        autoSaveTask?.cancel()
        
        // Schedule new auto-save after delay
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveDelay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performAutoSave()
            }
        }
    }
    
    func performAutoSave() async {
        // Don't auto-save if there are no changes
        guard hasUnsavedChanges else { return }
        
        // Don't auto-save if we're in the middle of another save
        guard !isAutoSaving else { return }
        
        isAutoSaving = true
        
        do {
            let book = createBook()
            
            // Determine save location
            let saveURL: URL
            if let existingURL = currentBookURL {
                // Save to existing location
                saveURL = existingURL
            } else {
                // Save to auto-save location
                saveURL = getAutoSaveURL()
                currentBookURL = saveURL
                // Update title from filename
                if let fileName = saveURL.deletingPathExtension().lastPathComponent as String? {
                    bookTitle = fileName
                }
            }
            
            // Perform save
            try await Task.detached {
                try BookService.shared.saveBook(book, to: saveURL)
            }.value
            
            // Mark as saved
            hasUnsavedChanges = false
            
        } catch {
            // Silently fail auto-save - don't interrupt user
            print("Auto-save failed: \(error.localizedDescription)")
        }
        
        isAutoSaving = false
    }
    
    private func getAutoSaveURL() -> URL {
        // Get or create auto-save directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let autoSaveDir = documentsURL.appendingPathComponent("Odyssey AutoSave", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: autoSaveDir.path) {
            try? fileManager.createDirectory(at: autoSaveDir, withIntermediateDirectories: true)
        }
        
        // Generate filename from book title (sanitized)
        let sanitizedTitle = bookTitle
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fileName = sanitizedTitle.isEmpty ? "Untitled Book" : sanitizedTitle
        return autoSaveDir.appendingPathComponent("\(fileName).book")
    }
    
    func startAutoSave() {
        // Start periodic auto-save (every 30 seconds as backup)
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performAutoSave()
            }
        }
    }
    
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        autoSaveTask?.cancel()
        autoSaveTask = nil
    }
}

