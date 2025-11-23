import Foundation
import SwiftUI

@MainActor
class NodeCanvasViewModel: ObservableObject {
    @Published var nodes: [Node] = []
    @Published var selectedNodeId: UUID?
    @Published var draggingNodeId: UUID?
    @Published var dragOffset: CGSize = .zero
    @Published var linkingFromNodeId: UUID?
    
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
    }
    
    func updateNode(_ nodeId: UUID, title: String? = nil, content: String? = nil) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        if let title = title {
            nodes[index].title = title
        }
        if let content = content {
            nodes[index].content = content
        }
    }
    
    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
        linkingFromNodeId = nil
    }
    
    func startLinking(from nodeId: UUID) {
        linkingFromNodeId = nodeId
    }
    
    func completeLinking(to nodeId: UUID) {
        guard let fromId = linkingFromNodeId, fromId != nodeId else {
            linkingFromNodeId = nil
            return
        }
        
        guard let fromIndex = nodes.firstIndex(where: { $0.id == fromId }) else {
            linkingFromNodeId = nil
            return
        }
        
        nodes[fromIndex].link(to: nodeId)
        linkingFromNodeId = nil
    }
    
    func removeLink(from: UUID, to: UUID) {
        guard let fromIndex = nodes.firstIndex(where: { $0.id == from }) else { return }
        nodes[fromIndex].unlink(from: to)
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
}

