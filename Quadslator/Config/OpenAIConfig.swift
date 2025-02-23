import Foundation

struct OpenAIConfig: Codable {
    let apiUrl: String
    let apiKey: String
    let translationPrompt: String
    
    static func load() -> OpenAIConfig? {
        guard let url = Bundle.main.url(forResource: "openai-config", withExtension: "json", subdirectory: "Config"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(OpenAIConfig.self, from: data) else {
            return nil
        }
        return config
    }
}