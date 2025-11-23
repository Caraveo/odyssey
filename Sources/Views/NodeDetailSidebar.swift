import SwiftUI

struct NodeDetailSidebar: View {
    let node: Node
    @ObservedObject var viewModel: NodeCanvasViewModel
    @Binding var generatedText: String
    @State private var editingContent: String = ""
    @State private var editingTitle: String = ""
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("Node Details")
                        .font(.custom("Courier", size: 18))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        viewModel.selectNode(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.custom("Courier", size: 12))
                        .foregroundColor(.secondary)
                    
                    TextField("Node title", text: $editingTitle)
                        .textFieldStyle(.roundedBorder)
                        .font(.custom("Courier", size: 14))
                        .onChange(of: editingTitle) { newValue in
                            viewModel.updateNode(node.id, title: newValue)
                        }
                }
                
                // Category
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.custom("Courier", size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(node.category.rawValue.capitalized)
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(node.category.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Content")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            // Open full-screen writing mode
                            NotificationCenter.default.post(
                                name: NSNotification.Name("OpenWritingMode"),
                                object: nil,
                                userInfo: ["nodeId": node.id, "content": editingContent]
                            )
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Full-screen writing mode")
                    }
                    
                    WritingView(text: $editingContent)
                        .frame(height: 400)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                        .onChange(of: editingContent) { newValue in
                            viewModel.updateNode(node.id, content: newValue)
                        }
                }
                
                // Generated text
                if !generatedText.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Generated")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            Text(generatedText)
                                .font(.custom("Courier", size: 14))
                                .lineSpacing(1.2)
                                .padding(.horizontal, 1.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 200)
                        .background(Color(NSColor.textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                        
                        Button("Use this content") {
                            editingContent = generatedText
                            viewModel.updateNode(node.id, content: generatedText)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Linked nodes
                if !node.linkedNodeIds.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Linked Nodes")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                        
                        ForEach(viewModel.getRelatedNodes(for: node.id)) { linkedNode in
                            HStack {
                                Text(linkedNode.title)
                                    .font(.custom("Courier", size: 12))
                                
                                Spacer()
                                
                                Button {
                                    viewModel.removeLink(from: node.id, to: linkedNode.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 12))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .frame(width: 400)
            .background(Color(NSColor.windowBackgroundColor))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: -4, y: 0)
        }
        .onAppear {
            editingTitle = node.title
            editingContent = node.content
        }
        .onChange(of: node.title) { _ in
            editingTitle = node.title
        }
        .onChange(of: node.content) { _ in
            editingContent = node.content
        }
    }
}

