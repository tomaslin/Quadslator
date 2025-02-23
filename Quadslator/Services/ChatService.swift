import Foundation

class ChatService {
    private let config: OpenAIConfig?
    
    init() {
        self.config = OpenAIConfig.load()
    }
    
    struct ChatMessage: Codable {
        let role: String
        let content: String
    }
    
    struct ChatRequest: Codable {
        let model: String
        let messages: [ChatMessage]
    }
    
    struct ChatResponse: Codable {
        struct Choice: Codable {
            let message: ChatMessage
        }
        let choices: [Choice]
    }
    
    func translate(text: String, to targetLanguage: String) async throws -> String {
        guard let config = self.config else {
            throw NSError(domain: "ChatService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Configuration not loaded"])
        }
        
        let prompt = config.translationPrompt
            .replacingOccurrences(of: "{text}", with: text)
            .replacingOccurrences(of: "{targetLanguage}", with: targetLanguage)
        
        let message = ChatMessage(role: "user", content: prompt)
        // Azure OpenAI requires the deployment name in the URL, not in the request body
        let request = ChatRequest(model: "gpt-4", messages: [message])
        
        guard let url = URL(string: config.apiUrl) else {
            throw NSError(domain: "ChatService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Azure OpenAI uses api-key header instead of Authorization
        urlRequest.addValue(config.apiKey, forHTTPHeaderField: "api-key")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "ChatService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "ChatService", code: 5, 
                         userInfo: [NSLocalizedDescriptionKey: "API request failed with status code: \(httpResponse.statusCode)"])
        }
        
        let apiResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        guard let translation = apiResponse.choices.first?.message.content else {
            throw NSError(domain: "ChatService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No translation received"])
        }
        
        return translation
    }
}