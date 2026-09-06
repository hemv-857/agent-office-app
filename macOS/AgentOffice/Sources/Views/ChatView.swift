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
                                // Message content with markdown
                                if msg.role == .assistant {
                                    ChatMarkdownView(content: msg.content)
                                } else {
                                    Text(msg.content)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: msg.role == .user ? .trailing : .leading)
                            if msg.role == .user { Spacer() }
                        }
                        .contextMenu {
                            Button("Copy") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(msg.content, forType: .string)
                            }
                            Button("Copy as Markdown") {
                                NSPasteboard.general.clearContents()
                                let md = msg.role == .user ? msg.content : "**\(agentName):** \(msg.content)"
                                NSPasteboard.general.setString(md, forType: .string)
                            }
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

// MARK: - Chat Markdown View
struct ChatMarkdownView: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(parseBlocks(content), id: \.id) { block in
                switch block.type {
                case .code:
                    ScrollView(.horizontal) {
                        Text(block.text)
                            .font(.system(size: 12, design: .monospaced))
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                    }
                case .heading:
                    Text(block.text)
                        .font(.system(size: 14, weight: .bold))
                case .bullet:
                    HStack(alignment: .top, spacing: 4) {
                        Text("•")
                        Text(block.text)
                            .font(.system(size: 13))
                    }
                case .text:
                    Text(block.text)
                        .font(.system(size: 13))
                }
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }

    private func parseBlocks(_ text: String) -> [ChatBlock] {
        var blocks: [ChatBlock] = []
        let lines = text.components(separatedBy: "\n")
        var inCode = false
        var codeContent = ""

        for line in lines {
            if line.hasPrefix("```") {
                if inCode {
                    blocks.append(ChatBlock(type: .code, text: codeContent))
                    codeContent = ""
                    inCode = false
                } else {
                    inCode = true
                }
            } else if inCode {
                if !codeContent.isEmpty { codeContent += "\n" }
                codeContent += line
            } else if line.hasPrefix("# ") {
                blocks.append(ChatBlock(type: .heading, text: String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                blocks.append(ChatBlock(type: .heading, text: String(line.dropFirst(3))))
            } else if line.hasPrefix("- ") || line.hasPrefix("• ") {
                blocks.append(ChatBlock(type: .bullet, text: String(line.dropFirst(2))))
            } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                blocks.append(ChatBlock(type: .text, text: line))
            }
        }

        if !codeContent.isEmpty {
            blocks.append(ChatBlock(type: .code, text: codeContent))
        }

        if blocks.isEmpty {
            blocks.append(ChatBlock(type: .text, text: text))
        }

        return blocks
    }
}

// MARK: - Chat Block
struct ChatBlock: Identifiable {
    let id = UUID()
    let type: BlockType
    let text: String

    enum BlockType {
        case code, heading, bullet, text
    }
}
