import SwiftUI
import AppKit

struct SettingsView: View {
    @Binding var selectedAIService: AIServiceType
    @Binding var aiModel: String
    @State private var availableModels: [String] = []
    @State private var isLoadingModels: Bool = false
    @State private var showCustomModel: Bool = false
    @AppStorage("darkMode") private var isDarkMode: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("AI Settings")
                    .font(.custom("Courier", size: 20))
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Appearance Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Appearance")
                    .font(.custom("Courier", size: 14))
                    .fontWeight(.semibold)
                
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .font(.custom("Courier", size: 12))
                    .onChange(of: isDarkMode) { newValue in
                        applyAppearance(newValue)
                    }
            }
            
            Divider()
            
            // AI Service Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Service")
                    .font(.custom("Courier", size: 14))
                    .fontWeight(.semibold)
                
                Picker("AI Service", selection: $selectedAIService) {
                    Text("Ollama").tag(AIServiceType.ollama)
                    Text("Mistral AI").tag(AIServiceType.mistral)
                    Text("MLX (MistyStudio)").tag(AIServiceType.mlx)
                    Text("OpenAI").tag(AIServiceType.openai)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedAIService) { _ in
                    loadModels()
                }
            }
            
            // Model Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Model")
                        .font(.custom("Courier", size: 14))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        loadModels()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .help("Refresh models")
                }
                
                if isLoadingModels {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading models...")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(.secondary)
                    }
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
                    .onChange(of: aiModel) { newValue in
                        if newValue == "__custom__" {
                            showCustomModel = true
                            aiModel = ""
                        }
                    }
                } else {
                    TextField("Model name", text: $aiModel)
                        .textFieldStyle(.roundedBorder)
                        .font(.custom("Courier", size: 12))
                        .help("Enter model name manually (e.g., mistral, llama2, gpt-4)")
                }
            }
            
            // Service-specific info
            VStack(alignment: .leading, spacing: 8) {
                Text("Service Information")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.secondary)
                
                Group {
                    switch selectedAIService {
                    case .ollama:
                        Text("Ollama runs locally. Make sure Ollama is running on http://localhost:11434")
                            .font(.custom("Courier", size: 11))
                            .foregroundColor(.secondary)
                    case .mlx:
                        Text("MLX/MistyStudio runs locally. Make sure MistyStudio is running on http://localhost:11973")
                            .font(.custom("Courier", size: 11))
                            .foregroundColor(.secondary)
                    case .openai:
                        Text("OpenAI requires an API key. Set OPENAI_API_KEY environment variable.")
                            .font(.custom("Courier", size: 11))
                            .foregroundColor(.secondary)
                    case .mistral:
                        Text("Mistral AI requires an API key. Set MISTRAL_API_KEY environment variable.")
                            .font(.custom("Courier", size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding(30)
        .frame(width: 500, height: 450)
        .onAppear {
            loadModels()
            // Apply saved appearance on load
            applyAppearance(isDarkMode)
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
    
    private func applyAppearance(_ darkMode: Bool) {
        if darkMode {
            NSApp.appearance = NSAppearance(named: .darkAqua)
        } else {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
    }
}

