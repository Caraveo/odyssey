import SwiftUI

struct NodeView: View {
    let node: Node
    let isSelected: Bool
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    private var isLinkSource: Bool {
        viewModel.isLinkingMode && viewModel.linkingFromNodeId == node.id
    }
    
    private var isLinkTargetCandidate: Bool {
        viewModel.isLinkingMode && viewModel.linkingFromNodeId != nil && viewModel.linkingFromNodeId != node.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: node.category.icon)
                    .foregroundColor(node.category.color)
                    .font(.system(size: 16))
                
                Text(node.title)
                    .font(.custom("Courier", size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Menu {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteNode(node.id)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if !node.content.isEmpty {
                Text(node.content)
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Text(node.category.rawValue.capitalized)
                .font(.custom("Courier", size: 10))
                .foregroundColor(node.category.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(node.category.color.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(12)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: isSelected ? node.category.color.opacity(0.5) : Color.black.opacity(0.1), radius: isSelected ? 8 : 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, style: borderStyle)
        )
        .offset(dragOffset)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        viewModel.draggingNodeId = node.id
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    isDragging = false
                    viewModel.draggingNodeId = nil
                    
                    // Update node position
                    if let index = viewModel.nodes.firstIndex(where: { $0.id == node.id }) {
                        viewModel.nodes[index].position.x += value.translation.width
                        viewModel.nodes[index].position.y += value.translation.height
                        viewModel.markAsChanged()
                    }
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            viewModel.handleNodeClick(node.id)
        }
        .onHover { hovering in
            guard viewModel.isLinkingMode, viewModel.linkingFromNodeId != node.id else {
                if viewModel.hoveredLinkTargetId == node.id {
                    viewModel.hoveredLinkTargetId = nil
                }
                return
            }
            
            if hovering {
                viewModel.hoveredLinkTargetId = node.id
            } else if viewModel.hoveredLinkTargetId == node.id {
                viewModel.hoveredLinkTargetId = nil
            }
        }
        .overlay(
            Group {
                if isLinkSource {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 3)
                } else if isLinkTargetCandidate {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.45), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }
            }
        )
        .overlay(alignment: .topTrailing) {
            if isLinkSource {
                linkBadge(label: "Source", systemImage: "link.circle.fill")
                    .offset(x: 18, y: -14)
            } else if isLinkTargetCandidate {
                linkBadge(label: "Link", systemImage: "plus.circle.fill")
                    .offset(x: 18, y: -14)
            }
        }
    }
    
    private var borderColor: Color {
        if isLinkSource {
            return .blue
        }
        
        if isSelected {
            return node.category.color
        }
        
        return .clear
    }
    
    private var borderStyle: StrokeStyle {
        if isLinkSource {
            return StrokeStyle(lineWidth: 3)
        }
        
        return StrokeStyle(lineWidth: 2)
    }
    
    @ViewBuilder
    private func linkBadge(label: String, systemImage: String) -> some View {
        Label(label, systemImage: systemImage)
            .font(.custom("Courier", size: 10))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.blue)
            )
    }
}
