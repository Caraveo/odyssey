import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var showingAddNode = false
    @State private var newNodeTitle = ""
    @State private var newNodeCategory: NodeCategory = .character
    
    var body: some View {
        HStack {
            Menu {
                Button("Add Character") {
                    newNodeCategory = .character
                    showingAddNode = true
                }
                Button("Add Plot") {
                    newNodeCategory = .plot
                    showingAddNode = true
                }
                Button("Add Conflict") {
                    newNodeCategory = .conflict
                    showingAddNode = true
                }
                Button("Add Concept") {
                    newNodeCategory = .concept
                    showingAddNode = true
                }
            } label: {
                Label("Add Node", systemImage: "plus.circle")
            }
            
            Spacer()
        }
        .padding()
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
        }
    }
}

struct AddNodeSheet: View {
    @Binding var title: String
    @Binding var category: NodeCategory
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Node")
                .font(.custom("Courier", size: 18))
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.custom("Courier", size: 12))
                
                TextField("Enter node title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("Courier", size: 14))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.custom("Courier", size: 12))
                
                Picker("Category", selection: $category) {
                    ForEach(NodeCategory.allCases) { cat in
                        Text(cat.rawValue.capitalized).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            HStack {
                Button("Cancel") {
                    title = ""
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Add") {
                    onAdd()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
}

