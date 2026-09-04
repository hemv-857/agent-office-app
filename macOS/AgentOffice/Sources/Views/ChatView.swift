// ChatView.swift
import SwiftUI

struct ChatView: View {
    let agentId: String
    let agentName: String
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var messages: [ChatMessage] {
        store.chatMessages[agentId] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Chat with \(agentName)").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Messages
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { msg in
                        HStack(alignment: .top, spacing: 8) {
                            if msg.role == .assistant {
                                Text(agentName.prefix(1))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 6))
                            }
                            VStack(alignment: msg.role == .user ? .trailing : .leading, spacing: 4) {
                                Text(msg.content)
                                    .font(.system(size: 13))
                                    .padding(8)
                                    .background(msg.role == .user ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
                                    .foregroundStyle(msg.role == .user ? .white : .primary)
                            }
                            if msg.role == .user { Spacer() }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Input
            HStack(spacing: 8) {
                TextField("Message...", text: $store.chatInput)
                    .textFieldStyle(.plain)
                    .onSubmit { store.sendChatMessage(to: agentId) }
                Button(action: { store.sendChatMessage(to: agentId) }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(store.chatInput.isEmpty ? Color.secondary : Color.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(store.chatInput.isEmpty)
            }
            .padding(10)
        }
        .frame(width: 450, height: 500)
    }
}
