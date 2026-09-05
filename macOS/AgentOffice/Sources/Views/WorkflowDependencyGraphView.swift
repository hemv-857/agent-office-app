// WorkflowDependencyGraphView.swift
import SwiftUI

struct WorkflowDependencyGraphView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let nodes: [(String, CGFloat, CGFloat)] = [
        ("Input", 100, 100),
        ("Analyze", 250, 80),
        ("Plan", 250, 180),
        ("Execute", 400, 130),
        ("Review", 550, 80),
        ("Output", 550, 180),
    ]

    private let edges: [(Int, Int)] = [
        (0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (3, 5)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Graph").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            GeometryReader { geometry in
                ZStack {
                    // Edges
                    ForEach(edges.indices, id: \.self) { i in
                        let edge = edges[i]
                        let start = CGPoint(x: nodes[edge.0].1, y: nodes[edge.0].2)
                        let end = CGPoint(x: nodes[edge.1].1, y: nodes[edge.1].2)

                        Path { path in
                            path.move(to: start)
                            path.addLine(to: end)
                        }
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 2)
                    }

                    // Nodes
                    ForEach(nodes.indices, id: \.self) { i in
                        let node = nodes[i]
                        GraphNode(
                            label: node.0,
                            position: CGPoint(x: node.1, y: node.2),
                            color: nodeColor(for: node.0)
                        )
                    }
                }
            }

            Divider()

            HStack {
                // Legend
                HStack(spacing: 12) {
                    LegendItem(color: .blue, label: "Input")
                    LegendItem(color: .green, label: "Processing")
                    LegendItem(color: .orange, label: "Output")
                }
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 650, height: 350)
    }

    func nodeColor(for name: String) -> Color {
        switch name {
        case "Input": return .blue
        case "Output": return .orange
        default: return .green
        }
    }
}

// MARK: - Graph Node
struct GraphNode: View {
    let label: String
    let position: CGPoint
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(label.prefix(3)))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                )
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .position(position)
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 9)).foregroundStyle(.secondary)
        }
    }
}
