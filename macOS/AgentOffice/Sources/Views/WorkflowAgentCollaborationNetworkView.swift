// WorkflowAgentCollaborationNetworkView.swift
import SwiftUI

struct WorkflowAgentCollaborationNetworkView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedAgent: String?

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner"]
    private let connections: [(String, String, Int)] = [
        ("Architect", "Builder", 45),
        ("Architect", "Planner", 32),
        ("Builder", "Reviewer", 38),
        ("Builder", "Tester", 28),
        ("Reviewer", "Tester", 22),
        ("Planner", "Architect", 25),
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

            HStack(spacing: 16) {
                // Network graph
                VStack {
                    Text("Agent Network")
                        .font(.system(size: 12, weight: .semibold))
                    ZStack {
                        // Draw nodes
                        ForEach(agents.indices, id: \.self) { index in
                            let angle = Double(index) * (2 * .pi / Double(agents.count)) - .pi / 2
                            let radius: Double = 100
                            let x = cos(angle) * radius
                            let y = sin(angle) * radius

                            Circle()
                                .fill(selectedAgent == agents[index] ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text(["🏗️", "🔨", "👀", "🧪", "📋"][index])
                                            .font(.system(size: 16))
                                        Text(agents[index])
                                            .font(.system(size: 7))
                                    }
                                )
                                .position(x: 130 + x, y: 130 + y)
                                .onTapGesture {
                                    selectedAgent = selectedAgent == agents[index] ? nil : agents[index]
                                }

                            // Connection lines
                            ForEach(connections, id: \.0) { conn in
                                if (conn.0 == agents[index] || conn.1 == agents[index]),
                                   let fromIdx = agents.firstIndex(of: conn.0),
                                   let toIdx = agents.firstIndex(of: conn.1) {
                                    let fromAngle = Double(fromIdx) * (2 * .pi / Double(agents.count)) - .pi / 2
                                    let toAngle = Double(toIdx) * (2 * .pi / Double(agents.count)) - .pi / 2
                                    let fromPt = CGPoint(x: 130 + cos(fromAngle) * 100, y: 130 + sin(fromAngle) * 100)
                                    let toPt = CGPoint(x: 130 + cos(toAngle) * 100, y: 130 + sin(toAngle) * 100)

                                    Path { p in
                                        p.move(to: fromPt)
                                        p.addLine(to: toPt)
                                    }
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: CGFloat(conn.2) / 15)
                                }
                            }
                        }
                    }
                    .frame(width: 260, height: 260)
                }

                // Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connections")
                        .font(.system(size: 12, weight: .semibold))

                    ForEach(connections, id: \.0) { conn in
                        HStack(spacing: 6) {
                            Text(conn.0)
                                .font(.system(size: 10))
                                .frame(width: 60, alignment: .leading)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                            Text(conn.1)
                                .font(.system(size: 10))
                                .frame(width: 60, alignment: .leading)
                            Spacer()
                            Text("\(conn.2)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }
                .frame(width: 200)
            }
            .padding()

            Divider()

            HStack {
                if let sel = selectedAgent {
                    Text("Selected: \(sel)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 540, height: 440)
    }
}
