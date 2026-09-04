// AgentMemoryManager.swift
import Foundation

actor AgentMemoryManager {
    static let shared = AgentMemoryManager()

    private let userDefaults = UserDefaults.standard
    private let keyPrefix = "agent_memory_"

    func memories(for agentId: String) -> [AgentMemoryEntry] {
        guard let data = userDefaults.data(forKey: keyPrefix + agentId),
              let entries = try? JSONDecoder().decode([AgentMemoryEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func addMemory(_ entry: AgentMemoryEntry, for agentId: String) {
        var entries = memories(for: agentId)
        entries.append(entry)
        if entries.count > 100 {
            entries = Array(entries.suffix(100))
        }
        if let data = try? JSONEncoder().encode(entries) {
            userDefaults.set(data, forKey: keyPrefix + agentId)
        }
    }

    func clearMemories(for agentId: String) {
        userDefaults.removeObject(forKey: keyPrefix + agentId)
    }

    func clearAll() {
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(keyPrefix) }
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}
