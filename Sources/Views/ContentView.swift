import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = NodeCanvasViewModel()
    @State private var promptText: String = ""
    @State private var selectedAIService: AIServiceType = .ollama
    @State private var aiModel: String = "mistral"
    @State private var isGenerating: Bool = false
    @State private var generatedText: String = ""
    @State private var errorMessage: String?
    @State private var showingWritingMode: Bool = false
    @State private var writingModeNodeId: UUID?
    @State private var writingModeContent: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            MenuBarView(viewModel: viewModel)
            
            ZStack {
                Color(NSColor.textBackgroundColor)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    NodeCanvasView(viewModel: viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    // Central Prompt Input
                    VStack {
                        Spacer()
                        
                        PromptInputView(
                            promptText: $promptText,
                            selectedAIService: $selectedAIService,
                            aiModel: $aiModel,
                            isGenerating: $isGenerating,
                            onGenerate: generateContent
                        )
                        .padding(.bottom, 40)
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                
                // Sidebar for node details
                if viewModel.selectedNode != nil && !showingWritingMode {
                    NodeDetailSidebar(
                        node: viewModel.selectedNode!,
                        viewModel: viewModel,
                        generatedText: $generatedText
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
        }
        .font(.custom("Courier", size: 14))
        .focusable()
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
        generatedText = ""
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
                    generatedText = response
                    isGenerating = false
                    
                    // Auto-update selected node content if available
                    if let selectedNodeId = viewModel.selectedNodeId {
                        viewModel.updateNode(selectedNodeId, content: response)
                    } else {
                        viewModel.markAsChanged()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
}

