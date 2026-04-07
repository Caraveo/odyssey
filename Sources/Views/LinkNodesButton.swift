import SwiftUI

struct LinkNodesButton: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    
    var body: some View {
        Button {
            viewModel.toggleLinkingMode()
        } label: {
            Image(systemName: viewModel.isLinkingMode ? "link.circle.fill" : "link.circle")
                .font(.system(size: 24))
                .foregroundColor(viewModel.isLinkingMode ? .blue : .primary)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                )
        }
        .buttonStyle(.plain)
        .help(viewModel.isLinkingMode ? "Linking Mode: choose a source node, hover another node to preview the direction arrow, then click to connect. Click again to exit." : "Link Nodes")
    }
}


