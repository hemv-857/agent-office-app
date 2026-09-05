// SessionManager.swift
import Foundation

class SessionManager: ObservableObject {
    static let shared = SessionManager()

    @Published var sessions: [Session] = []
    @Published var currentSession: Session?

    struct Session: Identifiable, Codable {
        let id: UUID
        var name: String
        var startDate: Date
        var endDate: Date?
        var promptHistory: [String]
        var results: [SessionResult]
        var notes: [SessionNote]
        var groupIds: [String]
        var presetIds: [String]
        var isActive: Bool
    }

    private init() {
        loadSessions()
    }

    func createSession(name: String) -> Session {
        let session = Session(
            id: UUID(),
            name: name,
            startDate: Date(),
            promptHistory: [],
            results: [],
            notes: [],
            groupIds: [],
            presetIds: [],
            isActive: true
        )

        sessions.append(session)
        currentSession = session
        saveSessions()
        return session
    }

    func endSession() {
        guard let sessionId = currentSession?.id,
              let index = sessions.firstIndex(where: { $0.id == sessionId }) else { return }

        sessions[index].endDate = Date()
        sessions[index].isActive = false
        currentSession = nil
        saveSessions()
    }

    func switchSession(_ session: Session) {
        endSession()
        currentSession = session
    }

    func deleteSession(_ session: Session) {
        sessions.removeAll { $0.id == session.id }
        if currentSession?.id == session.id {
            currentSession = nil
        }
        saveSessions()
    }

    func updateSession(_ session: Session) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }

    func addPromptToSession(_ prompt: String) {
        guard let sessionId = currentSession?.id,
              let index = sessions.firstIndex(where: { $0.id == sessionId }) else { return }

        sessions[index].promptHistory.append(prompt)
        saveSessions()
    }

    func addResultToSession(_ result: SessionResult) {
        guard let sessionId = currentSession?.id,
              let index = sessions.firstIndex(where: { $0.id == sessionId }) else { return }

        sessions[index].results.append(result)
        saveSessions()
    }

    func addNoteToSession(_ note: SessionNote) {
        guard let sessionId = currentSession?.id,
              let index = sessions.firstIndex(where: { $0.id == sessionId }) else { return }

        sessions[index].notes.append(note)
        saveSessions()
    }

    func getActiveSessions() -> [Session] {
        return sessions.filter { $0.isActive }
    }

    func getCompletedSessions() -> [Session] {
        return sessions.filter { !$0.isActive }
    }

    func getSessionDuration(_ session: Session) -> TimeInterval {
        let endDate = session.endDate ?? Date()
        return endDate.timeIntervalSince(session.startDate)
    }

    func getTotalSessions() -> Int {
        return sessions.count
    }

    func exportSession(_ session: Session) -> Data? {
        return try? JSONEncoder().encode(session)
    }

    func importSession(_ data: Data) -> Session? {
        guard let session = try? JSONDecoder().decode(Session.self, from: data) else { return nil }
        sessions.append(session)
        saveSessions()
        return session
    }

    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: "sessions")
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "sessions"),
           let loaded = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = loaded
            currentSession = sessions.first { $0.isActive }
        }
    }
}
