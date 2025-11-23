import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = NodeCanvasViewModel()
    @State private var promptText: String = ""
    @State private var selectedAIService: AIServiceType = .mlx
    @State private var aiModel: String = "mistral-7b"
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showingWritingMode: Bool = false
    @State private var writingModeNodeId: UUID?
    @State private var writingModeContent: String = ""
    @State private var showingSettings: Bool = false
    @State private var isNodeListCollapsed: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Node Hierarchy List (Left Side) - Collapsible
            if !isNodeListCollapsed {
                NodeHierarchyView(viewModel: viewModel, onCollapse: {
                    isNodeListCollapsed = true
                })
                .transition(.move(edge: .leading))
            } else {
                // Collapsed state - just a button
                VStack {
                    Button {
                        isNodeListCollapsed = false
                    } label: {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .help("Show Node List")
                    
                    Spacer()
                }
                .frame(width: 40)
                .padding(.top, 10)
                .background(Color(NSColor.windowBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color(NSColor.separatorColor)),
                    alignment: .trailing
                )
                .transition(.move(edge: .leading))
            }
            
            // Main Canvas Area
            ZStack {
                Color(NSColor.textBackgroundColor)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    NodeCanvasView(viewModel: viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    // Floating Buttons
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                AddNodeButton(viewModel: viewModel)
                                LinkNodesButton(viewModel: viewModel)
                            }
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                    
                    // Linking mode indicator
                    if viewModel.isLinkingMode {
                        VStack {
                            HStack {
                                Text("Linking Mode: Click a node, then click another to link")
                                    .font(.custom("Courier", size: 12))
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.leading, 20)
                    }
                    
                    // Bottom Prompt Input - Fixed at bottom
                    VStack {
                        Spacer()
                        
                        // Auto-save indicator
                        if viewModel.isAutoSaving {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Auto-saving...")
                                    .font(.custom("Courier", size: 10))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                            .padding(.bottom, 8)
                        }
                        
                        PromptInputView(
                            promptText: $promptText,
                            selectedAIService: $selectedAIService,
                            aiModel: $aiModel,
                            isGenerating: $isGenerating,
                            onGenerate: generateContent
                        )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                    .padding(.bottom, 20)
                    .padding(.trailing, 20 + geometry.size.width * 0.2) // Move 20% to the left (add to right padding)
                }
                
                // Sidebar for node details
                if let selectedNode = viewModel.selectedNode, !showingWritingMode {
                    NodeDetailSidebar(
                        node: selectedNode,
                        viewModel: viewModel
                    )
                    .id(selectedNode.id) // Force re-creation when node changes
                }
                
                // Full-screen writing mode
                if showingWritingMode {
                    WritingModeView(
                        content: $writingModeContent,
                        nodeId: writingModeNodeId,
                        viewModel: viewModel,
                        onClose: {
                            showingWritingMode = false
                            if let nodeId = writingModeNodeId {
                                viewModel.updateNode(nodeId, content: writingModeContent)
                            }
                        }
                    )
                }
            }
        }
        .font(.custom("Courier", size: 14))
        .focusable()
        .environmentObject(viewModel)
        .onAppear {
            // Ensure appearance is applied (fallback if delegate didn't run)
            let savedDarkMode = UserDefaults.standard.bool(forKey: "darkMode")
            if savedDarkMode {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            } else {
                NSApp.appearance = NSAppearance(named: .aqua)
            }
            // Ensure app has focus when view appears
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApplication.shared.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            // Start auto-save
            viewModel.startAutoSave()
        }
        .onDisappear {
            // Stop auto-save when view disappears
            viewModel.stopAutoSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBook"))) { notification in
            if let url = notification.userInfo?["url"] as? URL {
                do {
                    let book = try BookService.shared.loadBook(from: url)
                    viewModel.loadBook(book)
                    viewModel.currentBookURL = url
                    if let fileName = url.deletingPathExtension().lastPathComponent as String? {
                        viewModel.bookTitle = fileName
                    }
                } catch {
                    errorMessage = "Failed to open book: \(error.localizedDescription)"
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenWritingMode"))) { notification in
            if let nodeId = notification.userInfo?["nodeId"] as? UUID,
               let content = notification.userInfo?["content"] as? String {
                writingModeNodeId = nodeId
                writingModeContent = content
                showingWritingMode = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewBook"))) { _ in
            viewModel.newBook()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBookMenu"))) { _ in
            handleOpenBook()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveBook"))) { _ in
            handleSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveBookAs"))) { _ in
            handleSaveAs()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AddNode"))) { notification in
            if let category = notification.userInfo?["category"] as? NodeCategory {
                let center = CGPoint(x: 600, y: 400)
                viewModel.addNode(title: "New \(category.rawValue.capitalized)", category: category, at: center)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) { _ in
            showingSettings = true
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(selectedAIService: $selectedAIService, aiModel: $aiModel)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    private func generateContent() {
        guard !promptText.isEmpty else { return }
        
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let context: String
                let selectedNodeId: UUID?
                
                if let nodeId = viewModel.selectedNodeId {
                    // Use context from selected node
                    context = viewModel.getContextForPrompt()
                    selectedNodeId = nodeId
                } else {
                    // No node selected - create a new prompt node
                    context = "Generate creative content based on the following prompt."
                    selectedNodeId = nil
                }
                
                let response = try await AIService.shared.generateText(
                    prompt: promptText,
                    context: context,
                    service: selectedAIService,
                    model: aiModel
                )
                
                await MainActor.run {
                    isGenerating = false
                    
                    if let nodeId = selectedNodeId {
                        // Store AI results in the selected node
                        viewModel.updateNode(nodeId, aiResults: response)
                    } else {
                        // Create a new prompt node with the AI response
                        let nodeTitle = promptText.count > 50 ? String(promptText.prefix(47)) + "..." : promptText
                        
                        // Position new node in center of canvas (adjust based on existing nodes)
                        let existingNodes = viewModel.nodes
                        let centerX: CGFloat = 600
                        let centerY: CGFloat = 400
                        
                        // Offset slightly if there are existing nodes to avoid overlap
                        let offsetX = CGFloat(existingNodes.count % 5) * 50
                        let offsetY = CGFloat((existingNodes.count / 5) % 5) * 50
                        let position = CGPoint(x: centerX + offsetX, y: centerY + offsetY)
                        
                        viewModel.addNode(
                            title: nodeTitle,
                            category: .prompt,
                            at: position
                        )
                        
                        // Get the newly created node and set its content to the AI response
                        if let newNode = viewModel.nodes.last {
                            viewModel.updateNode(newNode.id, content: response)
                            viewModel.selectNode(newNode.id)
                        }
                    }
                    
                    // Clear prompt after successful generation
                    promptText = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
    
    private func handleOpenBook() {
        guard let url = BookService.shared.showOpenPanel() else { return }
        do {
            let book = try BookService.shared.loadBook(from: url)
            viewModel.loadBook(book)
            viewModel.currentBookURL = url
            if let fileName = url.deletingPathExtension().lastPathComponent as String? {
                viewModel.bookTitle = fileName
            }
        } catch {
            errorMessage = "Failed to open book: \(error.localizedDescription)"
        }
    }
    
    private func handleSave() {
        if let url = viewModel.currentBookURL {
            do {
                let book = viewModel.createBook()
                try BookService.shared.saveBook(book, to: url)
                viewModel.hasUnsavedChanges = false
            } catch {
                errorMessage = "Failed to save book: \(error.localizedDescription)"
            }
        } else {
            handleSaveAs()
        }
    }
    
    private func handleSaveAs() {
        guard let url = BookService.shared.showSavePanel(title: "Save Book") else { return }
        do {
            let book = viewModel.createBook()
            try BookService.shared.saveBook(book, to: url)
            viewModel.currentBookURL = url
            if let fileName = url.deletingPathExtension().lastPathComponent as String? {
                viewModel.bookTitle = fileName
            }
            viewModel.hasUnsavedChanges = false
        } catch {
            errorMessage = "Failed to save book: \(error.localizedDescription)"
        }
    }
}

