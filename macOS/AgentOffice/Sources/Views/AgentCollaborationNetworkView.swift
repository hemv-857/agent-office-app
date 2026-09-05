// AgentCollaborationNetworkView.swift
import SwiftUI

struct AgentCollaborationNetworkView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner"]
    private let connections: [(String, String, Double)] = [
        ("Architect", "Builder", 0.9),
        ("Architect", "Planner", 0.8),
        ("Builder", "Tester", 0.7),
        ("Builder", "Reviewer", 0.6),
        ("Tester", "Reviewer", 0.5),
        ("Planner", "Builder", 0.4),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Collaboration Network").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Network visualization
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 3

                ZStack {
                    // Connections
                    ForEach(connections.indices, id: \.self) { i in
                        let conn = connections[i]
                        if let fromIdx = agents.firstIndex(of: conn.0),
                           let toIdx = agents.firstIndex(of: conn.1) {
                            let fromPos = positionFor(index: fromIdx, center: center, radius: radius)
                            let toPos = positionFor(index: toIdx, center: center, radius: radius)
                            Path { path in
                                path.move(to: fromPos)
                                path.addLine(to: toPos)
                            }
                            .stroke(Color.accentColor.opacity(conn.2), lineWidth: conn.2 * 4)
                        }
                    }

                    // Agent nodes
                    ForEach(agents.indices, id: \.self) { i in
                        let pos = positionFor(index: i, center: center, radius: radius)
                        VStack(spacing: 2) {
                            Text(agents[i].prefix(1).uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                            Text(agents[i])
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 36, height: 36)
                        .background(Color.accentColor, in: Circle())
                        .position(pos)
                    }
                }
            }
            .padding()

            // Legend
            HStack(spacing: 16) {
                ForEach(connections.suffix(3), id: \.0) { conn in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.accentColor.opacity(conn.2))
                            .frame(width: 8, height: 8)
                        Text("\(conn.0)-\(conn.1)")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.bottom, 8)

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
    }

    private func positionFor(index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = (Double(index) / Double(agents.count)) * 2 * .pi - .pi / 2
        return CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius,
            y: center.y + CGFloat(sin(angle)) * radius
        )
    }
}
