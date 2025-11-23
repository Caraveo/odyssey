import Foundation
import SwiftUI

enum NodeCategory: String, CaseIterable, Identifiable, Codable {
    case character
    case plot
    case conflict
    case concept
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .character:
            return .blue
        case .plot:
            return .purple
        case .conflict:
            return .red
        case .concept:
            return .green
        }
    }
    
    var icon: String {
        switch self {
        case .character:
            return "person.fill"
        case .plot:
            return "book.fill"
        case .conflict:
            return "exclamationmark.triangle.fill"
        case .concept:
            return "lightbulb.fill"
        }
    }
}

struct Node: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var category: NodeCategory
    var position: CGPoint
    var linkedNodeIds: Set<UUID>
    var aiResults: String // Store AI-generated content for this node
    
    init(id: UUID = UUID(), title: String, content: String = "", category: NodeCategory, position: CGPoint = .zero, aiResults: String = "") {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.position = position
        self.linkedNodeIds = []
        self.aiResults = aiResults
    }
    
    mutating func link(to nodeId: UUID) {
        linkedNodeIds.insert(nodeId)
    }
    
    mutating func unlink(from nodeId: UUID) {
        linkedNodeIds.remove(nodeId)
    }
}

struct NodeConnection: Identifiable {
    let id: UUID
    let fromNodeId: UUID
    let toNodeId: UUID
    
    init(from: UUID, to: UUID) {
        self.id = UUID()
        self.fromNodeId = from
        self.toNodeId = to
    }
}

