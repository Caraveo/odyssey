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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 8)
        )
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

