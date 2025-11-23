import Foundation

struct Book: Codable {
    var title: String
    var nodes: [Node]
    var version: String = "1.0"
    
    init(title: String = "Untitled Book", nodes: [Node] = []) {
        self.title = title
        self.nodes = nodes
    }
}

