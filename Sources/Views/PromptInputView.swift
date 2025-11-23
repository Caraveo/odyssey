import SwiftUI

struct PromptInputView: View {
    @Binding var promptText: String
    @Binding var selectedAIService: AIServiceType
    @Binding var aiModel: String
    @Binding var isGenerating: Bool
    let onGenerate: () -> Void
    
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
                
                TextField("Model", text: $aiModel)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("Courier", size: 12))
                    .frame(width: 200)
                    .help("e.g., mistral, llama2, gpt-4, mistral-7b")
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
    }
}

