// LLMService.swift
import Foundation

struct LLMResponse {
    let text: String
    let tokens: Int
    let cost: Double
}

actor LLMService {
    private let provider: LLMProvider
    private let apiKey: String
    private let session = URLSession.shared

    init(provider: LLMProvider, apiKey: String) {
        self.provider = provider
        self.apiKey = apiKey
    }

    func execute(systemPrompt: String, userMessage: String) async throws -> LLMResponse {
        switch provider {
        case .anthropic:
            return try await callAnthropic(system: systemPrompt, user: userMessage)
        case .openai:
            return try await callOpenAI(system: systemPrompt, user: userMessage)
        case .ollama:
            return try await callOllama(system: systemPrompt, user: userMessage)
        }
    }

    // MARK: - Anthropic
    private func callAnthropic(system: String, user: String) async throws -> LLMResponse {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 4096,
            "system": system,
            "messages": [["role": "user", "content": user]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let errStr = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.apiError(errStr)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        let text = content?.first?["text"] as? String ?? ""
        let usage = json?["usage"] as? [String: Any]
        let inputTokens = usage?["input_tokens"] as? Int ?? 0
        let outputTokens = usage?["output_tokens"] as? Int ?? 0
        let totalTokens = inputTokens + outputTokens
        let cost = Double(inputTokens) * 3.0 / 1_000_000 + Double(outputTokens) * 15.0 / 1_000_000

        return LLMResponse(text: text, tokens: totalTokens, cost: cost)
    }

    // MARK: - OpenAI
    private func callOpenAI(system: String, user: String) async throws -> LLMResponse {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ],
            "max_tokens": 4096
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let errStr = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.apiError(errStr)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let text = message?["content"] as? String ?? ""
        let usage = json?["usage"] as? [String: Any]
        let totalTokens = (usage?["total_tokens"] as? Int) ?? 0
        let cost = Double(totalTokens) * 2.5 / 1_000_000

        return LLMResponse(text: text, tokens: totalTokens, cost: cost)
    }

    // MARK: - Ollama
    private func callOllama(system: String, user: String) async throws -> LLMResponse {
        var request = URLRequest(url: URL(string: "http://localhost:11434/api/chat")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 300

        let body: [String: Any] = [
            "model": "llama3",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ],
            "stream": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw LLMError.apiError("Ollama not running")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let message = json?["message"] as? [String: Any]
        let text = message?["content"] as? String ?? ""

        return LLMResponse(text: text, tokens: 0, cost: 0)
    }
}

enum LLMError: LocalizedError {
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .apiError(let msg): return msg
        }
    }
}
