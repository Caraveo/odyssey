import SwiftUI

struct NodeView: View {
    let node: Node
    let isSelected: Bool
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
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
                .stroke(isSelected ? node.category.color : Color.clear, lineWidth: 2)
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
        .overlay(
            // Highlight when in linking mode and this is the source node
            Group {
                if viewModel.isLinkingMode && viewModel.linkingFromNodeId == node.id {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 3)
                        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: viewModel.linkingFromNodeId)
                }
            }
        )
    }
}

