import Foundation

struct OpenAIConfig: Codable {
    let apiUrl: String
    let apiKey: String
    let translationPrompt: String

    static func load() -> OpenAIConfig? {
        guard let url = Bundle.main.url(forResource: "openai-config", withExtension: "json") else {
            print("Configuration file not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(OpenAIConfig.self, from: data)
            return config
        } catch {
            print("Error loading configuration: \(error)")
            return nil
        }
    }
}