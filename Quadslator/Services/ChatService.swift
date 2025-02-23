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
        let request = ChatRequest(model: "gpt-3.5-turbo", messages: [message])
        
        var urlRequest = URLRequest(url: URL(string: config.apiUrl)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        guard let translation = response.choices.first?.message.content else {
            throw NSError(domain: "ChatService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No translation received"])
        }
        
        return translation
    }
}