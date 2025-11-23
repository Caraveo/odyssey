import SwiftUI

struct NodeCanvasView: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var canvasOffset: CGSize = .zero
    @State private var lastPanLocation: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                Canvas { context, size in
                    drawGrid(context: context, size: size)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            canvasOffset = CGSize(
                                width: lastPanLocation.width + value.translation.width,
                                height: lastPanLocation.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastPanLocation = canvasOffset
                        }
                )
                
                // Connections
                ForEach(viewModel.connections) { connection in
                    if let fromNode = viewModel.nodes.first(where: { $0.id == connection.fromNodeId }),
                       let toNode = viewModel.nodes.first(where: { $0.id == connection.toNodeId }) {
                        ConnectionLine(
                            from: fromNode.position + canvasOffset,
                            to: toNode.position + canvasOffset,
                            onDelete: {
                                viewModel.removeLink(from: connection.fromNodeId, to: connection.toNodeId)
                            }
                        )
                    }
                }
                
                // Nodes
                ForEach(viewModel.nodes) { node in
                    NodeView(
                        node: node,
                        isSelected: viewModel.selectedNodeId == node.id,
                        viewModel: viewModel
                    )
                    .position(node.position + canvasOffset)
                }
                
                // Temporary linking line
                if let linkingFromId = viewModel.linkingFromNodeId,
                   let fromNode = viewModel.nodes.first(where: { $0.id == linkingFromId }) {
                    GeometryReader { geo in
                        Path { path in
                            let start = fromNode.position + canvasOffset
                            path.move(to: start)
                            path.addLine(to: CGPoint(
                                x: geo.size.width / 2,
                                y: geo.size.height / 2
                            ))
                        }
                        .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                }
            }
            .clipped()
            .onAppear {
                // Initialize with a few example nodes
                if viewModel.nodes.isEmpty {
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    viewModel.addNode(
                        title: "Main Character",
                        category: .character,
                        at: CGPoint(x: center.x - 200, y: center.y - 150)
                    )
                    viewModel.addNode(
                        title: "Opening Plot",
                        category: .plot,
                        at: CGPoint(x: center.x + 200, y: center.y - 150)
                    )
                    viewModel.addNode(
                        title: "Central Conflict",
                        category: .conflict,
                        at: CGPoint(x: center.x, y: center.y + 150)
                    )
                }
            }
        }
    }
    
    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let gridSize: CGFloat = 50
        let color = Color.gray.opacity(0.2)
        
        for x in stride(from: 0, through: size.width, by: gridSize) {
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                },
                with: .color(color),
                lineWidth: 1
            )
        }
        
        for y in stride(from: 0, through: size.height, by: gridSize) {
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                },
                with: .color(color),
                lineWidth: 1
            )
        }
    }
}

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    let onDelete: () -> Void
    @State private var isHovered: Bool = false
    
    var body: some View {
        ZStack {
            // Invisible hit area for clicking
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(Color.clear, lineWidth: 20)
            .contentShape(Path { path in
                path.move(to: from)
                path.addLine(to: to)
            })
            .onTapGesture {
                onDelete()
            }
            .onHover { hovering in
                isHovered = hovering
            }
            
            // Visible line
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(
                isHovered ? Color.red.opacity(0.6) : Color.blue.opacity(0.4),
                lineWidth: isHovered ? 3 : 2
            )
        }
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
}

