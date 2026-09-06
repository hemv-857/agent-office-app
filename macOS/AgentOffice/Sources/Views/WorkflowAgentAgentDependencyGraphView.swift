// WorkflowAgentAgentDependencyGraphView.swift
import SwiftUI

struct WorkflowAgentAgentDependencyGraphView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let nodes: [(String, String, Color)] = [
        ("Architect", "planner", .blue),
        ("Builder", "implementer", .green),
        ("Reviewer", "reviewer", .orange),
        ("Tester", "tester", .purple),
        ("Planner", "planner", .cyan),
        ("Security", "auditor", .red),
    ]

    private let edges: [(String, String, String)] = [
        ("Architect", "Builder", "designs"),
        ("Builder", "Reviewer", "submits"),
        ("Reviewer", "Tester", "approves"),
        ("Tester", "Builder", "feedback"),
        ("Planner", "Architect", "plans"),
        ("Security", "Reviewer", "audits"),
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

            // Legend
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(nodes.indices, id: \.self) { i in
                        HStack(spacing: 4) {
                            Circle().fill(nodes[i].2).frame(width: 10, height: 10)
                            Text(nodes[i].0).font(.system(size: 9))
                            Text("(\(nodes[i].1))").font(.system(size: 8)).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Graph visualization
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(nodes.indices, id: \.self) { i in
                        DependencyNodeRow(
                            name: nodes[i].0,
                            role: nodes[i].1,
                            color: nodes[i].2,
                            edges: edges.filter { $0.0 == nodes[i].0 }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 460)
    }
}

// MARK: - Dependency Node Row
struct DependencyNodeRow: View {
    let name: String
    let role: String
    let color: Color
    let edges: [(String, String, String)]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                if !edges.isEmpty {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 2, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(color)
                    Text(role)
                        .font(.system(size: 8))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(color.opacity(0.2), in: Capsule())
                        .foregroundStyle(color)
                }

                if !edges.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(edges, id: \.1) { edge in
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                Text(edge.2)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                Text("→")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.tertiary)
                                Text(edge.1)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}