import SwiftUI

struct PromptInputView: View {
    @Binding var promptText: String
    @Binding var selectedAIService: AIServiceType
    @Binding var aiModel: String
    @Binding var isGenerating: Bool
    let onGenerate: () -> Void
    @State private var availableModels: [String] = []
    @State private var isLoadingModels: Bool = false
    @State private var showCustomModel: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Picker("AI Service", selection: $selectedAIService) {
                    Text("Ollama").tag(AIServiceType.ollama)
                    Text("Mistral AI").tag(AIServiceType.mistral)
                    Text("MLX").tag(AIServiceType.mlx)
                    Text("OpenAI").tag(AIServiceType.openai)
                }
                .pickerStyle(.segmented)
                .frame(width: 400)
                .onChange(of: selectedAIService) { _ in
                    loadModels()
                }
                
                if isLoadingModels {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 200)
                } else if !availableModels.isEmpty {
                    Picker("Model", selection: $aiModel) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                        Divider()
                        Text("Custom...").tag("__custom__")
                    }
                    .pickerStyle(.menu)
                    .font(.custom("Courier", size: 12))
                    .frame(width: 200)
                    .onChange(of: aiModel) { newValue in
                        if newValue == "__custom__" {
                            showCustomModel = true
                            aiModel = ""
                        }
                    }
                } else {
                    TextField("Model", text: $aiModel)
                        .textFieldStyle(.roundedBorder)
                        .font(.custom("Courier", size: 12))
                        .frame(width: 200)
                        .help("Enter model name (e.g., mistral, llama2, gpt-4)")
                }
                
                Button {
                    loadModels()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .help("Refresh models")
            }
            
            HStack(spacing: 12) {
                TextField("Enter your prompt...", text: $promptText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("Courier", size: 14))
                    .lineSpacing(1.2)
                    .padding(.horizontal, 1.5)
                    .frame(width: 500)
                    .lineLimit(3...6)
                    .onSubmit {
                        if !promptText.isEmpty && !isGenerating {
                            onGenerate()
                        }
                    }
                
                Button(action: onGenerate) {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(promptText.isEmpty || isGenerating)
                .frame(width: 44, height: 44)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 8)
        )
        .onAppear {
            loadModels()
        }
        .sheet(isPresented: $showCustomModel) {
            CustomModelSheet(model: $aiModel, isPresented: $showCustomModel)
        }
    }
    
    private func loadModels() {
        isLoadingModels = true
        availableModels = []
        
        Task {
            do {
                let models = try await AIService.shared.fetchAvailableModels(for: selectedAIService)
                await MainActor.run {
                    availableModels = models
                    isLoadingModels = false
                    
                    // Set default model if available
                    if !models.isEmpty && (aiModel.isEmpty || !models.contains(aiModel)) {
                        // Try to set a sensible default
                        let defaultModel = getDefaultModel(for: selectedAIService, available: models)
                        aiModel = defaultModel ?? models.first ?? ""
                    }
                }
            } catch {
                await MainActor.run {
                    availableModels = []
                    isLoadingModels = false
                }
            }
        }
    }
    
    private func getDefaultModel(for service: AIServiceType, available: [String]) -> String? {
        switch service {
        case .ollama:
            return available.first { $0.contains("mistral") } ?? available.first
        case .mlx:
            return available.first { $0.contains("mistral") || $0.contains("7b") } ?? available.first
        case .openai:
            return available.first { $0.contains("gpt-4") } ?? available.first { $0.contains("gpt") } ?? available.first
        case .mistral:
            return available.first { $0.contains("large") } ?? available.first
        }
    }
}

struct CustomModelSheet: View {
    @Binding var model: String
    @Binding var isPresented: Bool
    @State private var customModel: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Custom Model Name")
                .font(.custom("Courier", size: 18))
                .fontWeight(.bold)
            
            TextField("Model name", text: $customModel)
                .textFieldStyle(.roundedBorder)
                .font(.custom("Courier", size: 14))
                .onSubmit {
                    if !customModel.isEmpty {
                        model = customModel
                        isPresented = false
                    }
                }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Use") {
                    if !customModel.isEmpty {
                        model = customModel
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(customModel.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
        .onAppear {
            customModel = model
        }
    }
}

