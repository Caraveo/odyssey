import SwiftUI
import AppKit

struct WritingModeView: View {
    @Binding var content: String
    let nodeId: UUID?
    @ObservedObject var viewModel: NodeCanvasViewModel
    let onClose: () -> Void
    @State private var nodeTitle: String = ""
    
    var body: some View {
        ZStack {
            Color(NSColor.textBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header bar
                HStack {
                    if let nodeId = nodeId,
                       let node = viewModel.nodes.first(where: { $0.id == nodeId }) {
                        Text(node.title)
                            .font(.custom("Courier", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("•")
                            .font(.custom("Courier", size: 14))
                            .foregroundColor(.secondary)
                        
                        Text(node.category.rawValue.capitalized)
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(node.category.color)
                    }
                    
                    Spacer()
                    
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(NSColor.separatorColor)),
                    alignment: .bottom
                )
                
                // Writing area
                WritingView(text: $content)
            }
        }
        .onAppear {
            if let nodeId = nodeId,
               let node = viewModel.nodes.first(where: { $0.id == nodeId }) {
                nodeTitle = node.title
            }
        }
    }
}




