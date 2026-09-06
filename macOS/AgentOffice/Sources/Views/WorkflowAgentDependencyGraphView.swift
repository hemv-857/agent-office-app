// WorkflowAgentDependencyGraphView.swift
import SwiftUI

struct WorkflowAgentDependencyGraphView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let nodes = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let edges: [(String, String)] = [
        ("Architect", "Builder"),
        ("Builder", "Reviewer"),
        ("Reviewer", "Tester"),
        ("Tester", "Planner"),
        ("Planner", "Architect"),
        ("Security", "Builder"),
        ("Security", "Reviewer"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Dependency Graph").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                Text("Agent Dependencies")
                    .font(.system(size: 12, weight: .semibold))

                // Dependency list
                GroupBox("Dependencies") {
                    VStack(spacing: 6) {
                        ForEach(edges, id: \.0) { edge in
                            HStack(spacing: 8) {
                                Text(edge.0)
                                    .font(.system(size: 11, weight: .medium))
                                    .frame(width: 80, alignment: .trailing)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                Text(edge.1)
                                    .font(.system(size: 11, weight: .medium))
                                    .frame(width: 80, alignment: .leading)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .padding(8)
                }

                // Critical path
                GroupBox("Critical Path") {
                    HStack(spacing: 6) {
                        ForEach(["Architect", "Builder", "Reviewer", "Tester"], id: \.self) { node in
                            Text(node)
                                .font(.system(size: 9))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.accentColor.opacity(0.1), in: Capsule())
                                .foregroundStyle(Color.accentColor)
                            if node != "Tester" {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(8)
                }

                // Stats
                HStack(spacing: 16) {
                    GraphStat(label: "Nodes", value: "\(nodes.count)")
                    GraphStat(label: "Edges", value: "\(edges.count)")
                    GraphStat(label: "Critical Path", value: "4 steps")
                    GraphStat(label: "Cycles", value: "1")
                }
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

// MARK: - Graph Stat
struct GraphStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
