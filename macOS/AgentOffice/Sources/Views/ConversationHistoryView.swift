// ConversationHistoryView.swift
import SwiftUI

struct ConversationHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var chatMessages: [PersistedChatMessage] = []
    @State private var searchText = ""
    @State private var selectedAgentId: String?

    private var filteredMessages: [PersistedChatMessage] {
        chatMessages.filter { msg in
            let matchesSearch = searchText.isEmpty || msg.content.localizedCaseInsensitiveContains(searchText)
            let matchesAgent = selectedAgentId == nil || msg.agentId == selectedAgentId
            return matchesSearch && matchesAgent
        }
    }

    private var agentNames: [String: String] {
        var map: [String: String] = [:]
        for agent in store.allAgents { map[agent.id] = agent.name }
        return map
    }

    private var uniqueAgentIds: [String] {
        Array(Set(chatMessages.compactMap(\.agentId))).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Conversation History").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filters
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search messages...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

            // Agent filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    FilterPill(title: "All", isSelected: selectedAgentId == nil) {
                        selectedAgentId = nil
                    }
                    ForEach(uniqueAgentIds, id: \.self) { agentId in
                        let name = agentNames[agentId] ?? agentId
                        FilterPill(title: name, isSelected: selectedAgentId == agentId) {
                            selectedAgentId = agentId
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }

            Divider()

            // Messages
            if filteredMessages.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.largeTitle).foregroundStyle(.secondary)
                    Text("No messages found").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredMessages) { msg in
                            MessageRow(message: msg, agentName: agentNames[msg.agentId ?? ""] ?? "Unknown")
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Text("\(filteredMessages.count) messages")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Clear History") {
                    UserDefaults.standard.removeObject(forKey: "chatHistory")
                    chatMessages = []
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 550, height: 500)
        .onAppear {
            loadMessages()
        }
    }

    func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "chatHistory"),
           let messages = try? JSONDecoder().decode([PersistedChatMessage].self, from: data) {
            chatMessages = messages.sorted { $0.timestamp > $1.timestamp }
        }
    }
}

// MARK: - Message Row
struct MessageRow: View {
    let message: PersistedChatMessage
    let agentName: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(message.role == "user" ? Color.blue : Color.green)
                .frame(width: 24, height: 24)
                .overlay(
                    Text(message.role == "user" ? "U" : String(agentName.prefix(1)))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(message.role == "user" ? "You" : agentName)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
                Text(message.content)
                    .font(.system(size: 11))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
