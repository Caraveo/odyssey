import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NodeCanvasViewModel()
    @State private var promptText: String = ""
    @State private var selectedAIService: AIServiceType = .ollama
    @State private var aiModel: String = "mistral"
    @State private var isGenerating: Bool = false
    @State private var generatedText: String = ""
    @State private var errorMessage: String?
    
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
                if viewModel.selectedNode != nil {
                    NodeDetailSidebar(
                        node: viewModel.selectedNode!,
                        viewModel: viewModel,
                        generatedText: $generatedText
                    )
                }
            }
        }
        .font(.custom("Courier", size: 14))
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

