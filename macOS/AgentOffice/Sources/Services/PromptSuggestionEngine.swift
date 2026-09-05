// PromptSuggestionEngine.swift
import Foundation

class PromptSuggestionEngine {
    static let shared = PromptSuggestionEngine()

    private let suggestions: [String: [String]] = [
        "analyze": [
            "Analyze the following data and provide insights",
            "What patterns do you see in this data?",
            "Compare and contrast these approaches",
        ],
        "write": [
            "Write a comprehensive guide about",
            "Create a detailed report covering",
            "Draft a professional email regarding",
        ],
        "code": [
            "Write a Swift function that",
            "Create a class implementing",
            "Refactor this code to improve",
        ],
        "review": [
            "Review this code for potential issues",
            "What improvements would you suggest?",
            "Check this for security vulnerabilities",
        ],
        "explain": [
            "Explain how this works in detail",
            "What is the purpose of this?",
            "Walk me through the process of",
        ],
    ]

    private init() {}

    func getSuggestions(for prompt: String) -> [String] {
        let lowercased = prompt.lowercased()
        var results: [String] = []

        for (keyword, keywordSuggestions) in suggestions {
            if lowercased.contains(keyword) {
                results.append(contentsOf: keywordSuggestions)
            }
        }

        if results.isEmpty {
            results = [
                "Can you help me with this?",
                "What do you think about this approach?",
                "Please provide your analysis",
            ]
        }

        return Array(results.prefix(5))
    }

    func getCategories() -> [String] {
        return Array(suggestions.keys).sorted()
    }

    func getTemplates(for category: String) -> [String] {
        return suggestions[category] ?? []
    }
}
