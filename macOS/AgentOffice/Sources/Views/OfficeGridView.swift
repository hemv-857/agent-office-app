// OfficeGridView.swift
import SwiftUI

struct OfficeGridView: View {
    @EnvironmentObject var store: AppStore

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(store.desks) { desk in
                    DeskCard(desk: desk)
                }
            }
            .padding(14)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Desk Card
struct DeskCard: View {
    let desk: Desk
    @EnvironmentObject var store: AppStore
    @State private var isDragOver = false

    var statusColor: Color {
        switch desk.status {
        case .idle: return .secondary
        case .working: return .blue
        case .done: return .green
        case .error: return .red
        case .blocked: return .orange
        }
    }

    var statusIcon: String {
        switch desk.status {
        case .idle: return "circle.dashed"
        case .working: return "arrow.triangle.2.circlepath"
        case .done: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .blocked: return "exclamationmark.triangle.fill"
        }
    }

    var result: SessionResult? {
        guard let agent = desk.agent else { return nil }
        return store.results.first(where: { $0.agentId == agent.id })
    }

    var body: some View {
        VStack(spacing: 6) {
            if let agent = desk.agent {
                // Agent avatar
                ZStack {
                    Text(agent.initials)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 10)
                        )

                    if desk.status == .working {
                        ProgressView()
                            .controlSize(.mini)
                            .offset(x: 18, y: -18)
                    }
                }

                Text(agent.name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                Text(agent.officeRole)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)

                // Status indicator
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 8))
                        .foregroundStyle(statusColor)
                    Text(desk.status.rawValue.capitalized)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.1), in: Capsule())

                // Quick result preview
                if let result = result, result.status == .done {
                    Text(result.response.prefix(60) + (result.response.count > 60 ? "..." : ""))
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }

                // Action buttons
                HStack(spacing: 8) {
                    Button(action: {
                        store.showAgentDetail = agent
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .help("View details")

                    Button(action: {
                        store.showChat = ChatDestination(agentId: agent.id, agentName: agent.name)
                    }) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .help("Chat with agent")

                    Button(action: { store.removeAgent(from: desk.role) }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary.opacity(0.6))
                    .help("Remove from desk")
                }
                .padding(.top, 2)

            } else {
                // Empty desk
                Image(systemName: "plus.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(.tertiary)

                Text(desk.role.rawValue.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 120)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(desk.isOccupied ? Color.accentColor.opacity(0.04) : Color(nsColor: .windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isDragOver ? Color.accentColor : Color.secondary.opacity(0.1),
                            lineWidth: isDragOver ? 2 : 1
                        )
                )
        )
        .scaleEffect(isDragOver ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isDragOver)
        .onDrop(of: [.text], delegate: DeskDropDelegate(desk: desk, store: store, isDragOver: $isDragOver))
    }
}

// MARK: - Drop Delegate
struct DeskDropDelegate: DropDelegate {
    let desk: Desk
    let store: AppStore
    @Binding var isDragOver: Bool

    func performDrop(info: DropInfo) -> Bool { true }

    func dropEntered(info: DropInfo) {
        isDragOver = true
    }

    func dropExited(info: DropInfo) {
        isDragOver = false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .copy)
    }
}
