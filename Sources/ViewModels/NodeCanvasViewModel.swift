import Foundation
import SwiftUI

@MainActor
class NodeCanvasViewModel: ObservableObject {
    @Published var nodes: [Node] = []
    @Published var selectedNodeId: UUID?
    @Published var draggingNodeId: UUID?
    @Published var dragOffset: CGSize = .zero
    @Published var linkingFromNodeId: UUID?
    @Published var hoveredLinkTargetId: UUID?
    @Published var isLinkingMode: Bool = false
    @Published var currentBookURL: URL?
    @Published var bookTitle: String = "Untitled Book"
    @Published var hasUnsavedChanges: Bool = false
    @Published var isAutoSaving: Bool = false
    @Published var saveStatusMessage: String = "New draft not yet saved"
    
    private var periodicAutoSaveTimer: Timer?
    private var autoSaveTask: Task<Void, Never>?
    private var changeRevision: Int = 0
    private var recoverySessionID: UUID = UUID()
    private let autoSaveDelay: TimeInterval = 3.0
    private let periodicAutoSaveInterval: TimeInterval = 30.0
    
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
        for index in nodes.indices {
            nodes[index].linkedNodeIds.remove(nodeId)
        }
        if selectedNodeId == nodeId {
            selectedNodeId = nil
        }
        markAsChanged()
    }
    
    func updateNode(_ nodeId: UUID, title: String? = nil, content: String? = nil, aiResults: String? = nil) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        
        if let title, nodes[index].title != title {
            nodes[index].title = title
            markAsChanged()
        }
        
        if let content, nodes[index].content != content {
            nodes[index].content = content
            markAsChanged()
        }
        
        if let aiResults, nodes[index].aiResults != aiResults {
            nodes[index].aiResults = aiResults
            markAsChanged()
        }
    }
    
    func updateTemplateValue(for nodeId: UUID, key: String, value: String) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        
        let normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentValue = nodes[index].templateValues[key] ?? ""
        
        if normalizedValue.isEmpty {
            guard nodes[index].templateValues.removeValue(forKey: key) != nil else { return }
            markAsChanged()
            return
        }
        
        guard currentValue != normalizedValue else { return }
        nodes[index].templateValues[key] = normalizedValue
        markAsChanged()
    }
    
    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
        if !isLinkingMode {
            linkingFromNodeId = nil
            hoveredLinkTargetId = nil
        }
    }
    
    func toggleLinkingMode() {
        isLinkingMode.toggle()
        if isLinkingMode {
            linkingFromNodeId = selectedNodeId
            hoveredLinkTargetId = nil
        } else {
            linkingFromNodeId = nil
            hoveredLinkTargetId = nil
        }
    }
    
    func handleNodeClick(_ nodeId: UUID) {
        if isLinkingMode {
            if let fromId = linkingFromNodeId {
                if fromId != nodeId {
                    guard let fromIndex = nodes.firstIndex(where: { $0.id == fromId }) else {
                        linkingFromNodeId = nil
                        hoveredLinkTargetId = nil
                        return
                    }
                    nodes[fromIndex].link(to: nodeId)
                    markAsChanged()
                }
                linkingFromNodeId = nil
                hoveredLinkTargetId = nil
            } else {
                linkingFromNodeId = nodeId
                hoveredLinkTargetId = nil
            }
        } else {
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
        
        var context = "Selected Node: \(selectedNode.title) (\(selectedNode.category.displayName))\n"
        context += "Content: \(selectedNode.content.isEmpty ? "No content yet" : selectedNode.content)\n\n"
        context += templateContext(for: selectedNode)
        
        if !selectedNode.linkedNodeIds.isEmpty {
            context += "Linked Nodes:\n"
            for linkedId in selectedNode.linkedNodeIds {
                if let linkedNode = nodes.first(where: { $0.id == linkedId }) {
                    context += "- \(linkedNode.title) (\(linkedNode.category.displayName))\n"
                    context += "  Content: \(linkedNode.content.isEmpty ? "No content" : linkedNode.content)\n"
                    let linkedTemplateContext = templateContext(for: linkedNode, indent: "  ")
                    if !linkedTemplateContext.isEmpty {
                        context += linkedTemplateContext
                    }
                }
            }
        }
        
        return context
    }
    
    func getRelatedNodes(for nodeId: UUID) -> [Node] {
        guard let node = nodes.first(where: { $0.id == nodeId }) else { return [] }
        return nodes.filter { node.linkedNodeIds.contains($0.id) }
    }
    
    func loadBook(_ book: Book, from url: URL? = nil) {
        cancelScheduledAutoSave()
        nodes = book.nodes
        currentBookURL = url
        bookTitle = url?.deletingPathExtension().lastPathComponent ?? book.title
        selectedNodeId = nil
        linkingFromNodeId = nil
        isLinkingMode = false
        hasUnsavedChanges = false
        changeRevision = 0
        recoverySessionID = UUID()
        saveStatusMessage = url == nil ? "Draft loaded" : "Opened \(bookTitle)"
    }
    
    func loadRecoveredSnapshot(_ snapshot: RecoverySnapshot) {
        cancelScheduledAutoSave()
        nodes = snapshot.book.nodes
        currentBookURL = snapshot.sourceBookURL
        bookTitle = snapshot.sourceBookURL?.deletingPathExtension().lastPathComponent ?? snapshot.book.title
        selectedNodeId = nil
        linkingFromNodeId = nil
        isLinkingMode = false
        hasUnsavedChanges = true
        changeRevision = 0
        recoverySessionID = snapshot.sessionID
        saveStatusMessage = "Recovered draft from \(Self.formattedTime(snapshot.capturedAt))"
    }
    
    func createBook() -> Book {
        Book(title: bookTitle, nodes: nodes)
    }
    
    func newBook() {
        cancelScheduledAutoSave()
        nodes = []
        selectedNodeId = nil
        linkingFromNodeId = nil
        isLinkingMode = false
        currentBookURL = nil
        bookTitle = "Untitled Book"
        hasUnsavedChanges = false
        changeRevision = 0
        recoverySessionID = UUID()
        saveStatusMessage = "New draft not yet saved"
    }
    
    func markAsChanged() {
        changeRevision += 1
        hasUnsavedChanges = true
        saveStatusMessage = currentBookURL == nil
            ? "Changes pending recovery"
            : "Changes pending auto-save"
        scheduleAutoSave()
    }
    
    func flushPendingAutosave() {
        cancelScheduledAutoSave()
        performAutoSave()
    }
    
    func saveBook(to url: URL) throws {
        cancelScheduledAutoSave()
        let previousURL = currentBookURL
        let fileName = url.deletingPathExtension().lastPathComponent
        let book = Book(title: fileName, nodes: nodes)
        
        try BookService.shared.saveBook(book, to: url)
        
        currentBookURL = url
        bookTitle = fileName
        hasUnsavedChanges = false
        saveStatusMessage = "Saved \(Self.formattedTime(Date()))"
        
        try? RecoveryService.shared.deleteSnapshot(for: previousURL, sessionID: recoverySessionID)
        if previousURL != url {
            try? RecoveryService.shared.deleteSnapshot(for: url, sessionID: recoverySessionID)
        }
    }
    
    func startAutoSave() {
        periodicAutoSaveTimer?.invalidate()
        periodicAutoSaveTimer = Timer.scheduledTimer(withTimeInterval: periodicAutoSaveInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.performAutoSave()
            }
        }
    }
    
    func stopAutoSave() {
        periodicAutoSaveTimer?.invalidate()
        periodicAutoSaveTimer = nil
        cancelScheduledAutoSave()
    }
    
    func performAutoSave() {
        guard hasUnsavedChanges else { return }
        guard !isAutoSaving else { return }
        
        autoSaveTask = nil
        isAutoSaving = true
        let revisionBeingSaved = changeRevision
        
        do {
            let outcome = try persist(book: createBook(), sourceURL: currentBookURL)
            
            if outcome.savedToBook, revisionBeingSaved == changeRevision {
                hasUnsavedChanges = false
            }
            
            saveStatusMessage = outcome.savedToBook
                ? "Auto-saved \(Self.formattedTime(outcome.savedAt))"
                : "Recovery updated \(Self.formattedTime(outcome.savedAt))"
        } catch {
            saveStatusMessage = "Recovery failed. Please save manually."
            print("Auto-save failed: \(error.localizedDescription)")
        }
        
        isAutoSaving = false
        
        if revisionBeingSaved != changeRevision {
            scheduleAutoSave()
        }
    }
    
    private func scheduleAutoSave() {
        cancelScheduledAutoSave()
        let delayInNanoseconds = UInt64(autoSaveDelay * 1_000_000_000)
        
        autoSaveTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: delayInNanoseconds)
            } catch {
                return
            }
            
            await MainActor.run {
                self?.performAutoSave()
            }
        }
    }
    
    private func cancelScheduledAutoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = nil
    }
    
    private func persist(book: Book, sourceURL: URL?) throws -> PersistOutcome {
        var recoveryError: Error?
        var snapshot: RecoverySnapshot?
        
        do {
            snapshot = try RecoveryService.shared.saveSnapshot(
                book: book,
                sourceBookURL: sourceURL,
                sessionID: recoverySessionID
            )
        } catch {
            recoveryError = error
        }
        
        if let sourceURL {
            try BookService.shared.saveBook(book, to: sourceURL)
            try? RecoveryService.shared.deleteSnapshot(for: sourceURL, sessionID: recoverySessionID)
            return PersistOutcome(savedAt: Date(), savedToBook: true)
        }
        
        if let snapshot {
            return PersistOutcome(savedAt: snapshot.capturedAt, savedToBook: false)
        }
        
        throw recoveryError ?? NSError(
            domain: "NodeCanvasViewModel",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Unable to persist recovery snapshot."]
        )
    }
    
    private static func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    private func templateContext(for node: Node, indent: String = "") -> String {
        let filledFields = node.filledTemplateFields
        guard !filledFields.isEmpty else { return "" }
        
        var context = "\(indent)\(node.category.displayName) Template:\n"
        for field in filledFields {
            context += "\(indent)- \(field.field.label): \(field.value)\n"
        }
        context += "\n"
        return context
    }
}

private struct PersistOutcome {
    let savedAt: Date
    let savedToBook: Bool
}
