import Foundation
import SwiftUI

enum NodeCategory: String, CaseIterable, Identifiable, Codable {
    case character
    case plot
    case conflict
    case concept
    case theme
    case setting
    case scene
    case dialogue
    case symbol
    case motif
    case foreshadowing
    case resolution
    case climax
    case exposition
    case risingAction
    case fallingAction
    case worldbuilding
    case subplot
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .risingAction:
            return "Rising Action"
        case .fallingAction:
            return "Falling Action"
        default:
            return rawValue.capitalized
        }
    }
    
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
        case .theme:
            return .orange
        case .setting:
            return .brown
        case .scene:
            return .cyan
        case .dialogue:
            return .yellow
        case .symbol:
            return .pink
        case .motif:
            return .indigo
        case .foreshadowing:
            return .teal
        case .resolution:
            return .mint
        case .climax:
            return Color(red: 0.8, green: 0.2, blue: 0.4)
        case .exposition:
            return .gray
        case .risingAction:
            return Color(red: 0.9, green: 0.5, blue: 0.1)
        case .fallingAction:
            return Color(red: 0.5, green: 0.3, blue: 0.7)
        case .worldbuilding:
            return Color(red: 0.2, green: 0.6, blue: 0.8)
        case .subplot:
            return Color(red: 0.7, green: 0.4, blue: 0.9)
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
        case .theme:
            return "theatermasks.fill"
        case .setting:
            return "map.fill"
        case .scene:
            return "camera.fill"
        case .dialogue:
            return "bubble.left.and.bubble.right.fill"
        case .symbol:
            return "star.fill"
        case .motif:
            return "repeat.circle.fill"
        case .foreshadowing:
            return "eye.fill"
        case .resolution:
            return "checkmark.circle.fill"
        case .climax:
            return "flame.fill"
        case .exposition:
            return "doc.text.fill"
        case .risingAction:
            return "arrow.up.circle.fill"
        case .fallingAction:
            return "arrow.down.circle.fill"
        case .worldbuilding:
            return "globe.americas.fill"
        case .subplot:
            return "list.bullet.rectangle.fill"
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

