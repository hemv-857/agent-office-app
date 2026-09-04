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

    var body: some View {
        VStack(spacing: 6) {
            if let agent = desk.agent {
                // Occupied desk
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

                Text(agent.name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                // Status dot
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    Text(desk.status.rawValue.capitalized)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }

                // Remove button
                Button(action: { store.removeAgent(from: desk.role) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .opacity(isSeated ? 1 : 0)

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
        .frame(minHeight: 100)
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

    private var isSeated: Bool { desk.agent != nil }
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
