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
    
    var body: some View {
        ZStack {
                Color(NSColor.textBackgroundColor)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    NodeCanvasView(viewModel: viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    // Floating Add Node Button
                    VStack {
                        HStack {
                            Spacer()
                            AddNodeButton(viewModel: viewModel)
                                .padding(.top, 20)
                                .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                    
                    // Bottom Prompt Input - Fixed at bottom
                    VStack {
                        Spacer()
                        
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
                    .padding(.horizontal, 20)
                }
                
                // Sidebar for node details
                if viewModel.selectedNode != nil && !showingWritingMode {
                    NodeDetailSidebar(
                        node: viewModel.selectedNode!,
                        viewModel: viewModel
                    )
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
        .font(.custom("Courier", size: 14))
        .focusable()
        .environmentObject(viewModel)
        .onAppear {
            // Ensure app has focus when view appears
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApplication.shared.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
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
        guard let selectedNodeId = viewModel.selectedNodeId else {
            errorMessage = "Please select a node first"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let context = viewModel.getContextForPrompt()
                let response = try await AIService.shared.generateText(
                    prompt: promptText,
                    context: context,
                    service: selectedAIService,
                    model: aiModel
                )
                
                await MainActor.run {
                    isGenerating = false
                    
                    // Store AI results in the selected node
                    viewModel.updateNode(selectedNodeId, aiResults: response)
                    
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

