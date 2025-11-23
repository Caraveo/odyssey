import SwiftUI

struct AddNodeButton: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var showingAddNode = false
    @State private var newNodeTitle = ""
    @State private var newNodeCategory: NodeCategory = .character
    
    var body: some View {
        Button {
            showingAddNode = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(.plain)
        .help("Add Node")
        .sheet(isPresented: $showingAddNode) {
            AddNodeSheet(
                title: $newNodeTitle,
                category: $newNodeCategory,
                onAdd: {
                    let center = CGPoint(x: 600, y: 400) // Default center position
                    viewModel.addNode(
                        title: newNodeTitle,
                        category: newNodeCategory,
                        at: center
                    )
                    newNodeTitle = ""
                    showingAddNode = false
                }
            )
            .onDisappear {
                // Reset form when sheet is dismissed
                newNodeTitle = ""
            }
        }
    }
}

