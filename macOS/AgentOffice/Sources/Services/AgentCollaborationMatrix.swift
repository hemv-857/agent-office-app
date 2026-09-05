// AgentCollaborationMatrix.swift
import Foundation

class AgentCollaborationMatrix: ObservableObject {
    static let shared = AgentCollaborationMatrix()

    @Published var collaborations: [String: CollaborationData] = [:]

    struct CollaborationData: Codable {
        let agentPair: String  // "agentId1:agentId2"
        var jointTasks: Int = 0
        var avgSynergy: Double = 0.0
        var lastCollaboration: Date?
        var successRate: Double = 1.0
    }

    private init() {
        loadCollaborations()
    }

    func recordCollaboration(agentId1: String, agentId2: String, synergy: Double, success: Bool) {
        let key = normalizePair(agentId1, agentId2)
        var data = collaborations[key] ?? CollaborationData(agentPair: key)

        data.jointTasks += 1
        data.lastCollaboration = Date()

        // Update average synergy
        let totalSynergy = data.avgSynergy * Double(data.jointTasks - 1) + synergy
        data.avgSynergy = totalSynergy / Double(data.jointTasks)

        // Update success rate
        let totalTasks = data.jointTasks
        let successCount = Double(totalTasks) * data.successRate + (success ? 1.0 : 0.0)
        data.successRate = successCount / Double(totalTasks)

        collaborations[key] = data
        saveCollaborations()
    }

    func getCollaborationScore(agentId1: String, agentId2: String) -> Double {
        let key = normalizePair(agentId1, agentId2)
        guard let data = collaborations[key] else { return 0.5 }

        return data.avgSynergy * data.successRate
    }

    func getBestCollaborators(for agentId: String, limit: Int) -> [(String, Double)] {
        var scores: [String: Double] = [:]

        for (key, data) in collaborations {
            let parts = key.split(separator: ":").map(String.init)
            guard parts.count == 2 else { continue }

            let otherId: String?
            if parts[0] == agentId {
                otherId = parts[1]
            } else if parts[1] == agentId {
                otherId = parts[0]
            } else {
                otherId = nil
            }

            if let other = otherId {
                scores[other] = data.avgSynergy * data.successRate
            }
        }

        return scores.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }

    func getCollaborationMatrix() -> [[String: Double]] {
        var allAgents = Set<String>()
        for key in collaborations.keys {
            let parts = key.split(separator: ":").map(String.init)
            if parts.count == 2 {
                allAgents.insert(parts[0])
                allAgents.insert(parts[1])
            }
        }

        let sortedAgents = Array(allAgents).sorted()
        var matrix: [[String: Double]] = []

        for agent1 in sortedAgents {
            var row: [String: Double] = [:]
            for agent2 in sortedAgents {
                if agent1 == agent2 {
                    row[agent2] = 1.0
                } else {
                    row[agent2] = getCollaborationScore(agentId1: agent1, agentId2: agent2)
                }
            }
            matrix.append(row)
        }

        return matrix
    }

    private func normalizePair(_ id1: String, _ id2: String) -> String {
        return id1 < id2 ? "\(id1):\(id2)" : "\(id2):\(id1)"
    }

    private func saveCollaborations() {
        if let data = try? JSONEncoder().encode(collaborations) {
            UserDefaults.standard.set(data, forKey: "agentCollaborations")
        }
    }

    private func loadCollaborations() {
        if let data = UserDefaults.standard.data(forKey: "agentCollaborations"),
           let collabs = try? JSONDecoder().decode([String: CollaborationData].self, from: data) {
            collaborations = collabs
        }
    }
}
