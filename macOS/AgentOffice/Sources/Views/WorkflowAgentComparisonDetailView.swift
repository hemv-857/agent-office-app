// WorkflowAgentComparisonDetailView.swift
import SwiftUI

struct WorkflowAgentComparisonDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, String, Double, Double, Double)] = [
        ("Arch", "🏗️", 0.85, 0.92, 0.02),
        ("Build", "🔧", 0.78, 0.88, 0.03),
        ("Review", "🔍", 0.92, 0.95, 0.01),
        ("Test", "🧪", 0.88, 0.90, 0.02),
        ("Plan", "📋", 0.82, 0.86, 0.02),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Comparison").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Comparison table
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Agent").frame(width: 60, alignment: .leading)
                            Text("Speed").frame(maxWidth: .infinity)
                            Text("Quality").frame(maxWidth: .infinity)
                            Text("Cost").frame(maxWidth: .infinity)
                        }
                        .font(.system(size: 9, weight: .semibold))
                        .padding(.vertical, 4)

                        Divider()

                        // Rows
                        ForEach(agents, id: \.0) { agent in
                            HStack {
                                HStack(spacing: 4) {
                                    Text(agent.1)
                                    Text(agent.0)
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .frame(width: 60, alignment: .leading)

                                Text(String(format: "%.0f%%", agent.2 * 100))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(agent.2 > 0.9 ? .green : .secondary)

                                Text(String(format: "%.0f%%", agent.3 * 100))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(agent.3 > 0.9 ? .green : .secondary)

                                Text(String(format: "$%.3f", agent.4))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 4)

                            if agent.0 != agents.last?.0 {
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Best picks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommendations").font(.system(size: 12, weight: .semibold))
                        HStack {
                            Image(systemName: "bolt.fill").foregroundStyle(.yellow)
                            Text("Fastest: Review agent (0.92 speed)")
                                .font(.system(size: 10))
                        }
                        HStack {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                            Text("Best quality: Review agent (0.95 quality)")
                                .font(.system(size: 10))
                        }
                        HStack {
                            Image(systemName: "dollarsign.circle.fill").foregroundStyle(.green)
                            Text("Most cost-effective: Review agent ($0.01)")
                                .font(.system(size: 10))
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}
