import SwiftUI

struct NodeCanvasView: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var canvasOffset: CGSize = .zero
    @State private var lastPanLocation: CGSize = .zero
    
    private let nodeHalfWidth: CGFloat = 110
    private let nodeHalfHeight: CGFloat = 58
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                
                ForEach(viewModel.connections) { connection in
                    if let fromNode = viewModel.nodes.first(where: { $0.id == connection.fromNodeId }),
                       let toNode = viewModel.nodes.first(where: { $0.id == connection.toNodeId }),
                       let endpoints = anchoredEndpoints(
                        from: fromNode.position + canvasOffset,
                        to: toNode.position + canvasOffset
                       ) {
                        DirectionalConnectionLine(
                            from: endpoints.start,
                            to: endpoints.end,
                            color: Color.blue.opacity(0.4),
                            lineWidth: 2,
                            dash: [],
                            onDelete: {
                                viewModel.removeLink(from: connection.fromNodeId, to: connection.toNodeId)
                            }
                        )
                    }
                }
                
                if let sourceId = viewModel.linkingFromNodeId,
                   let targetId = viewModel.hoveredLinkTargetId,
                   let sourceNode = viewModel.nodes.first(where: { $0.id == sourceId }),
                   let targetNode = viewModel.nodes.first(where: { $0.id == targetId }),
                   let previewEndpoints = anchoredEndpoints(
                    from: sourceNode.position + canvasOffset,
                    to: targetNode.position + canvasOffset
                   ) {
                    DirectionalConnectionLine(
                        from: previewEndpoints.start,
                        to: previewEndpoints.end,
                        color: Color.blue.opacity(0.75),
                        lineWidth: 2,
                        dash: [8, 6]
                    )
                }
                
                ForEach(viewModel.nodes) { node in
                    NodeView(
                        node: node,
                        isSelected: viewModel.selectedNodeId == node.id,
                        viewModel: viewModel
                    )
                    .position(node.position + canvasOffset)
                }
            }
            .clipped()
            .onAppear {
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
    
    private func anchoredEndpoints(from sourceCenter: CGPoint, to targetCenter: CGPoint) -> (start: CGPoint, end: CGPoint)? {
        let deltaX = targetCenter.x - sourceCenter.x
        let deltaY = targetCenter.y - sourceCenter.y
        let length = sqrt((deltaX * deltaX) + (deltaY * deltaY))
        
        guard length > 1 else { return nil }
        
        let direction = CGVector(dx: deltaX / length, dy: deltaY / length)
        let startOffset = edgeOffset(for: direction)
        let endOffset = edgeOffset(for: CGVector(dx: -direction.dx, dy: -direction.dy))
        
        return (
            start: CGPoint(x: sourceCenter.x + startOffset.dx, y: sourceCenter.y + startOffset.dy),
            end: CGPoint(x: targetCenter.x + endOffset.dx, y: targetCenter.y + endOffset.dy)
        )
    }
    
    private func edgeOffset(for direction: CGVector) -> CGVector {
        let scaleX = abs(direction.dx) > 0.001 ? nodeHalfWidth / abs(direction.dx) : .greatestFiniteMagnitude
        let scaleY = abs(direction.dy) > 0.001 ? nodeHalfHeight / abs(direction.dy) : .greatestFiniteMagnitude
        let scale = min(scaleX, scaleY)
        
        return CGVector(
            dx: direction.dx * scale,
            dy: direction.dy * scale
        )
    }
}

struct DirectionalConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    let color: Color
    let lineWidth: CGFloat
    let dash: [CGFloat]
    var onDelete: (() -> Void)? = nil
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        ZStack {
            if let onDelete {
                connectionPath
                    .stroke(Color.clear, lineWidth: 20)
                    .contentShape(connectionPath)
                    .onTapGesture {
                        onDelete()
                    }
                    .onHover { hovering in
                        isHovered = hovering
                    }
            }
            
            connectionPath
                .stroke(displayColor, style: StrokeStyle(lineWidth: effectiveLineWidth, lineCap: .round, lineJoin: .round, dash: dash))
            
            arrowHeadPath
                .fill(displayColor)
        }
    }
    
    private var displayColor: Color {
        if onDelete != nil && isHovered {
            return Color.red.opacity(0.65)
        }
        
        return color
    }
    
    private var effectiveLineWidth: CGFloat {
        if onDelete != nil && isHovered {
            return lineWidth + 1
        }
        
        return lineWidth
    }
    
    private var connectionPath: Path {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
    }
    
    private var arrowHeadPath: Path {
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 14
        let arrowSpread: CGFloat = .pi / 7
        
        let wingOne = CGPoint(
            x: to.x - cos(angle - arrowSpread) * arrowLength,
            y: to.y - sin(angle - arrowSpread) * arrowLength
        )
        let wingTwo = CGPoint(
            x: to.x - cos(angle + arrowSpread) * arrowLength,
            y: to.y - sin(angle + arrowSpread) * arrowLength
        )
        
        return Path { path in
            path.move(to: to)
            path.addLine(to: wingOne)
            path.addLine(to: wingTwo)
            path.closeSubpath()
        }
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
}
