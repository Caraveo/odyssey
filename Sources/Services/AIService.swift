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
    
    func fetchAvailableModels(for service: AIServiceType) async throws -> [String] {
        switch service {
        case .ollama:
            return try await fetchOllamaModels()
        case .mlx:
            return try await fetchMLXModels()
        case .openai:
            return try await fetchOpenAIModels()
        case .mistral:
            return try await fetchMistralModels()
        }
    }
    
    private func fetchOllamaModels() async throws -> [String] {
        let url = URL(string: "\(ollamaBaseURL)/api/tags")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return [] // Return empty if Ollama is not running
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let models = json["models"] as? [[String: Any]] {
            return models.compactMap { model in
                model["name"] as? String
            }
        }
        
        return []
    }
    
    private func fetchMLXModels() async throws -> [String] {
        let url = URL(string: "\(mlxBaseURL)/v1/models")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return [] // Return empty if MLX is not running
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let models = json["data"] as? [[String: Any]] {
            return models.compactMap { model in
                model["id"] as? String
            }
        }
        
        return []
    }
    
    private func fetchOpenAIModels() async throws -> [String] {
        guard let apiKey = openAIAPIKey ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return [] // Return empty if no API key
        }
        
        let url = URL(string: "https://api.openai.com/v1/models")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let models = json["data"] as? [[String: Any]] {
            // Filter for chat models only
            return models.compactMap { model in
                guard let id = model["id"] as? String else { return nil }
                // Only include chat completion models
                if id.contains("gpt") || id.contains("o1") || id.contains("chat") {
                    return id
                }
                return nil
            }.sorted()
        }
        
        return []
    }
    
    private func fetchMistralModels() async throws -> [String] {
        guard let apiKey = mistralAPIKey ?? ProcessInfo.processInfo.environment["MISTRAL_API_KEY"] else {
            return [] // Return empty if no API key
        }
        
        let url = URL(string: "https://api.mistral.ai/v1/models")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let models = json["data"] as? [[String: Any]] {
            return models.compactMap { model in
                model["id"] as? String
            }.sorted()
        }
        
        return []
    }
    
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
            return filterReasoning(from: content)
        }
        
        throw AIError.invalidResponse
    }
    
    private func filterReasoning(from content: String) -> String {
        var filtered = content
        
        // Remove reasoning sections (case-insensitive)
        // Pattern: "Reasoning:" or "Reasoning\n" followed by content until next section or end
        let reasoningPatterns = [
            "(?i)Reasoning:\\s*[\\s\\S]*?(?=\\n\\n|\\n[A-Z]|$)",
            "(?i)<reasoning>[\\s\\S]*?</reasoning>",
            "(?i)Reasoning\\s*\\n[\\s\\S]*?(?=\\n\\n|$)"
        ]
        
        for pattern in reasoningPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: filtered.utf16.count)
                filtered = regex.stringByReplacingMatches(in: filtered, options: [], range: range, withTemplate: "")
            }
        }
        
        // Remove any standalone "Reasoning:" lines
        filtered = filtered.replacingOccurrences(of: "(?i)^Reasoning:.*$", with: "", options: .regularExpression)
        
        // Clean up extra whitespace
        filtered = filtered.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return filtered
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

