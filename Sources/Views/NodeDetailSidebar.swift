import SwiftUI

struct NodeDetailSidebar: View {
    let node: Node
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var editingContent: String = ""
    @State private var editingTitle: String = ""
    @State private var editingTemplateValues: [String: String] = [:]
    @State private var isUpdating: Bool = false
    
    private var templateDefinition: NodeTemplateDefinition {
        node.category.templateDefinition
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Title")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                        
                        TextField("Node title", text: $editingTitle)
                            .textFieldStyle(.roundedBorder)
                            .font(.custom("Courier", size: 14))
                            .onChange(of: editingTitle) { newValue in
                                guard !isUpdating else { return }
                                viewModel.updateNode(node.id, title: newValue)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(node.category.displayName)
                            .font(.custom("Courier", size: 14))
                            .foregroundColor(node.category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(node.category.displayName) Template")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(templateDefinition.helperText)
                            .font(.custom("Courier", size: 11))
                            .foregroundColor(.secondary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        ForEach(templateDefinition.fields) { field in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(field.label)
                                    .font(.custom("Courier", size: 11))
                                    .foregroundColor(.primary)
                                
                                TextField(field.placeholder, text: templateBinding(for: field))
                                    .textFieldStyle(.roundedBorder)
                                    .font(.custom("Courier", size: 13))
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.65))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Content")
                                .font(.custom("Courier", size: 12))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button {
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
                            .frame(minHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            )
                            .onChange(of: editingContent) { newValue in
                                guard !isUpdating else { return }
                                viewModel.updateNode(node.id, content: newValue)
                            }
                    }
                    
                    if !node.aiResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 12))
                                
                                Text("AI Generated")
                                    .font(.custom("Courier", size: 12))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(node.aiResults)
                                        .font(.custom("Courier", size: 14))
                                        .lineSpacing(1.5)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(minHeight: 150, maxHeight: 400)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.purple.opacity(0.05),
                                                Color.blue.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.purple.opacity(0.3),
                                                Color.blue.opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            
                            HStack(spacing: 8) {
                                Button {
                                    let separator = editingContent.isEmpty ? "" : "\n\n"
                                    let newContent = editingContent + separator + node.aiResults
                                    editingContent = newContent
                                    viewModel.updateNode(node.id, content: newContent)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 11))
                                        Text("Keep this Content")
                                            .font(.custom("Courier", size: 12))
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.purple)
                                
                                Button {
                                    viewModel.updateNode(node.id, aiResults: "")
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 11))
                                        Text("Clear")
                                            .font(.custom("Courier", size: 12))
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    
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
                }
                .padding(20)
            }
            .frame(width: 400)
            .background(Color(NSColor.windowBackgroundColor))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: -4, y: 0)
        }
        .onAppear {
            syncEditingState(from: node)
        }
        .onChange(of: node.id) { _ in
            syncEditingState(from: node)
        }
        .onChange(of: node.title) { newValue in
            guard !isUpdating, editingTitle != newValue else { return }
            editingTitle = newValue
        }
        .onChange(of: node.content) { newValue in
            guard !isUpdating, editingContent != newValue else { return }
            editingContent = newValue
        }
        .onChange(of: node.templateValues) { newValue in
            guard !isUpdating, editingTemplateValues != newValue else { return }
            editingTemplateValues = newValue
        }
    }
    
    private func syncEditingState(from node: Node) {
        isUpdating = true
        editingTitle = node.title
        editingContent = node.content
        editingTemplateValues = node.templateValues
        isUpdating = false
    }
    
    private func templateBinding(for field: NodeTemplateField) -> Binding<String> {
        Binding(
            get: {
                editingTemplateValues[field.id] ?? ""
            },
            set: { newValue in
                editingTemplateValues[field.id] = newValue
                guard !isUpdating else { return }
                viewModel.updateTemplateValue(for: node.id, key: field.id, value: newValue)
            }
        )
    }
}
