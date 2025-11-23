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
    case protagonist
    case antagonist
    case narrator
    case pointOfView
    case tone
    case mood
    case atmosphere
    case backstory
    case flashback
    case metaphor
    case irony
    case tension
    case pacing
    case voice
    case style
    case genre
    case trope
    case archetype
    case emotion
    case relationship
    case memory
    case dream
    case prophecy
    case quest
    case transformation
    case prompt
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .risingAction:
            return "Rising Action"
        case .fallingAction:
            return "Falling Action"
        case .pointOfView:
            return "Point of View"
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
        case .protagonist:
            return Color(red: 0.1, green: 0.5, blue: 0.9)
        case .antagonist:
            return Color(red: 0.9, green: 0.1, blue: 0.2)
        case .narrator:
            return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .pointOfView:
            return Color(red: 0.3, green: 0.7, blue: 0.5)
        case .tone:
            return Color(red: 0.8, green: 0.6, blue: 0.2)
        case .mood:
            return Color(red: 0.5, green: 0.3, blue: 0.6)
        case .atmosphere:
            return Color(red: 0.4, green: 0.5, blue: 0.7)
        case .backstory:
            return Color(red: 0.7, green: 0.5, blue: 0.3)
        case .flashback:
            return Color(red: 0.6, green: 0.7, blue: 0.4)
        case .metaphor:
            return Color(red: 0.9, green: 0.4, blue: 0.6)
        case .irony:
            return Color(red: 0.4, green: 0.8, blue: 0.9)
        case .tension:
            return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .pacing:
            return Color(red: 0.5, green: 0.8, blue: 0.3)
        case .voice:
            return Color(red: 0.8, green: 0.4, blue: 0.8)
        case .style:
            return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .genre:
            return Color(red: 0.9, green: 0.7, blue: 0.2)
        case .trope:
            return Color(red: 0.6, green: 0.2, blue: 0.8)
        case .archetype:
            return Color(red: 0.2, green: 0.8, blue: 0.6)
        case .emotion:
            return Color(red: 0.9, green: 0.5, blue: 0.4)
        case .relationship:
            return Color(red: 0.4, green: 0.6, blue: 0.9)
        case .memory:
            return Color(red: 0.7, green: 0.6, blue: 0.8)
        case .dream:
            return Color(red: 0.5, green: 0.4, blue: 0.9)
        case .prophecy:
            return Color(red: 0.9, green: 0.8, blue: 0.3)
        case .quest:
            return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .transformation:
            return Color(red: 0.3, green: 0.7, blue: 0.8)
        case .prompt:
            return .black
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
        case .protagonist:
            return "person.crop.circle.fill"
        case .antagonist:
            return "person.crop.circle.badge.minus.fill"
        case .narrator:
            return "person.wave.2.fill"
        case .pointOfView:
            return "eye.circle.fill"
        case .tone:
            return "music.note.fill"
        case .mood:
            return "cloud.fill"
        case .atmosphere:
            return "moon.fill"
        case .backstory:
            return "clock.arrow.circlepath.fill"
        case .flashback:
            return "arrow.counterclockwise.circle.fill"
        case .metaphor:
            return "sparkles"
        case .irony:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .tension:
            return "bolt.fill"
        case .pacing:
            return "speedometer"
        case .voice:
            return "mic.fill"
        case .style:
            return "paintbrush.fill"
        case .genre:
            return "book.closed.fill"
        case .trope:
            return "repeat.1.circle.fill"
        case .archetype:
            return "person.3.fill"
        case .emotion:
            return "heart.fill"
        case .relationship:
            return "person.2.fill"
        case .memory:
            return "brain.head.profile"
        case .dream:
            return "moon.zzz.fill"
        case .prophecy:
            return "crystal.ball.fill"
        case .quest:
            return "map.circle.fill"
        case .transformation:
            return "arrow.triangle.2.circlepath"
        case .prompt:
            return "text.bubble.fill"
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

