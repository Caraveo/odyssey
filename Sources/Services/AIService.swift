import Foundation

enum AIServiceType: String, CaseIterable {
    case mistral = "Mistral AI"
    case ollama = "Ollama"
    case mlx = "MLX (MistyStudio)"
    case openai = "OpenAI"
}

class AIService {
    static let shared = AIService()
    
    private let mistralAPIKey: String? = nil // Set via environment variable
    private let openAIAPIKey: String? = nil // Set via environment variable
    private let ollamaBaseURL = "http://localhost:11434"
    private let mlxBaseURL = "http://localhost:11973"
    
    private init() {}
    
    func generateText(
        prompt: String,
        context: String,
        service: AIServiceType,
        model: String = "mistral" // or "llama2" for Ollama
    ) async throws -> String {
        let fullPrompt = """
        Context:
        \(context)
        
        Prompt:
        \(prompt)
        
        Please provide a creative and well-written response based on the context above.
        """
        
        switch service {
        case .mistral:
            return try await callMistralAPI(prompt: fullPrompt, model: model)
        case .ollama:
            return try await callOllamaAPI(prompt: fullPrompt, model: model)
        case .mlx:
            return try await callMLXAPI(prompt: fullPrompt, model: model)
        case .openai:
            return try await callOpenAIAPI(prompt: fullPrompt, model: model)
        }
    }
    
    private func callMistralAPI(prompt: String, model: String) async throws -> String {
        guard let apiKey = mistralAPIKey ?? ProcessInfo.processInfo.environment["MISTRAL_API_KEY"] else {
            throw AIError.missingAPIKey
        }
        
        let url = URL(string: "https://api.mistral.ai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("Failed to get response from Mistral API")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw AIError.invalidResponse
    }
    
    private func callOllamaAPI(prompt: String, model: String) async throws -> String {
        let url = URL(string: "\(ollamaBaseURL)/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("Failed to get response from Ollama API. Make sure Ollama is running on \(ollamaBaseURL)")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseText = json["response"] as? String {
            return responseText
        }
        
        throw AIError.invalidResponse
    }
    
    private func callMLXAPI(prompt: String, model: String) async throws -> String {
        let url = URL(string: "\(mlxBaseURL)/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("Failed to get response from MLX/MistyStudio API. Make sure MistyStudio is running on \(mlxBaseURL)")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw AIError.invalidResponse
    }
    
    private func callOpenAIAPI(prompt: String, model: String) async throws -> String {
        guard let apiKey = openAIAPIKey ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw AIError.missingAPIKey
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("Failed to get response from OpenAI API")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw AIError.invalidResponse
    }
}

enum AIError: LocalizedError {
    case missingAPIKey
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key not found. Set MISTRAL_API_KEY or OPENAI_API_KEY environment variable."
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from AI service"
        }
    }
}

