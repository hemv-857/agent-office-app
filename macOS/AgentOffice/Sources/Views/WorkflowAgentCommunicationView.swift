// WorkflowAgentCommunicationView.swift
import SwiftUI

struct WorkflowAgentCommunicationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let messages: [(String, String, String, String, Color)] = [
        ("Architect", "Builder", "Design specs ready for implementation", "Just now", .blue),
        ("Builder", "Reviewer", "PR #42 submitted for review", "2 min ago", .green),
        ("Reviewer", "Builder", "2 minor issues found in line 45", "5 min ago", .orange),
        ("Tester", "Planner", "Test coverage dropped to 82%", "8 min ago", .orange),
        ("Security", "Builder", "No vulnerabilities in latest scan", "12 min ago", .green),
        ("Planner", "Architect", "New requirements for v2.0", "15 min ago", .purple),
    ]

    private let channels: [(String, Int, Color)] = [
        ("General", 12, .blue),
        ("Code Review", 8, .green),
        ("Bug Reports", 3, .orange),
        ("Security", 2, .red),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Communication").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Channels
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(channels.indices, id: \.self) { i in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(channels[i].2)
                                .frame(width: 6, height: 6)
                            Text(channels[i].0)
                                .font(.system(size: 10, weight: .medium))
                            Text("\(channels[i].1)")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(channels[i].2.opacity(0.1), in: Capsule())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Messages
            List {
                ForEach(messages.indices, id: \.self) { i in
                    CommunicationMessageRow(
                        from: messages[i].0,
                        to: messages[i].1,
                        message: messages[i].2,
                        time: messages[i].3,
                        color: messages[i].4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            // Send message
            HStack(spacing: 8) {
                TextField("Type a message...", text: .constant(""))
                    .textFieldStyle(.plain)
                Button("Send") {
                    store.showToast("Message sent", type: .success)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Communication Message Row
struct CommunicationMessageRow: View {
    let from: String
    let to: String
    let message: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(from)
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text(to)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(time)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
