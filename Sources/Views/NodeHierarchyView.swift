import SwiftUI

struct NodeHierarchyView: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    let onCollapse: () -> Void
    @State private var expandedCategories: Set<NodeCategory> = Set(NodeCategory.allCases)
    
    var nodesByCategory: [NodeCategory: [Node]] {
        Dictionary(grouping: viewModel.nodes) { $0.category }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Nodes")
                    .font(.custom("Courier", size: 16))
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Button {
                        // Toggle all categories
                        if expandedCategories.count == NodeCategory.allCases.count {
                            expandedCategories.removeAll()
                        } else {
                            expandedCategories = Set(NodeCategory.allCases)
                        }
                    } label: {
                        Image(systemName: expandedCategories.count == NodeCategory.allCases.count ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(expandedCategories.count == NodeCategory.allCases.count ? "Collapse All" : "Expand All")
                    
                    Button {
                        onCollapse()
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Collapse Node List")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Node list grouped by category
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(NodeCategory.allCases) { category in
                        if let nodes = nodesByCategory[category], !nodes.isEmpty {
                            CategorySection(
                                category: category,
                                nodes: nodes,
                                isExpanded: expandedCategories.contains(category),
                                selectedNodeId: viewModel.selectedNodeId,
                                onToggle: {
                                    if expandedCategories.contains(category) {
                                        expandedCategories.remove(category)
                                    } else {
                                        expandedCategories.insert(category)
                                    }
                                },
                                onSelectNode: { nodeId in
                                    viewModel.selectNode(nodeId)
                                }
                            )
                        }
                    }
                    
                    if viewModel.nodes.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                            Text("No nodes yet")
                                .font(.custom("Courier", size: 12))
                                .foregroundColor(.secondary)
                            Text("Click + to add a node")
                                .font(.custom("Courier", size: 11))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
            }
        }
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .trailing
        )
    }
}

struct CategorySection: View {
    let category: NodeCategory
    let nodes: [Node]
    let isExpanded: Bool
    let selectedNodeId: UUID?
    let onToggle: () -> Void
    let onSelectNode: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category header
            Button {
                onToggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                        .foregroundColor(category.color)
                    
                    Text(category.displayName)
                        .font(.custom("Courier", size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(nodes.count)")
                        .font(.custom("Courier", size: 10))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(category.color.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(
                Rectangle()
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
            
            // Nodes in this category
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(nodes) { node in
                        NodeRow(
                            node: node,
                            isSelected: selectedNodeId == node.id,
                            onSelect: {
                                onSelectNode(node.id)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct NodeRow: View {
    let node: Node
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 8) {
                // Indentation
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 12)
                
                // Node icon
                Image(systemName: node.category.icon)
                    .font(.system(size: 11))
                    .foregroundColor(node.category.color.opacity(0.7))
                    .frame(width: 16)
                
                // Node title
                Text(node.title)
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ?
                node.category.color.opacity(0.15) :
                Color.clear
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(
            Rectangle()
                .fill(isSelected ? node.category.color : Color.clear)
                .frame(width: 3),
            alignment: .leading
        )
    }
}

