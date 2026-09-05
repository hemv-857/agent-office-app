// WorkflowCostBreakdownView.swift
import SwiftUI

struct WorkflowCostBreakdownView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Breakdown").font(.headline)
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
                    // By mode
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Workflow Mode").font(.system(size: 12, weight: .semibold))
                        CostBar(label: "Parallel", value: 0.35, color: .blue)
                        CostBar(label: "Pipeline", value: 0.25, color: .green)
                        CostBar(label: "Synthesis", value: 0.20, color: .purple)
                        CostBar(label: "Review", value: 0.15, color: .orange)
                        CostBar(label: "Debate", value: 0.05, color: .red)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // By agent
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Agent").font(.system(size: 12, weight: .semibold))
                        ForEach(store.allAgents.prefix(5)) { agent in
                            HStack {
                                Text(agent.emoji)
                                Text(agent.name)
                                    .font(.system(size: 11))
                                Spacer()
                                let cost = Double.random(in: 0.01...0.1)
                                Text(String(format: "$%.3f", cost))
                                    .font(.system(size: 10, design: .monospaced))
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Total
                    HStack {
                        Text("Total Cost")
                            .font(.system(size: 12, weight: .semibold))
                        Spacer()
                        Text(String(format: "$%.4f", store.todayCost))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 420, height: 480)
    }
}

// MARK: - Cost Bar
struct CostBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .frame(width: 70, alignment: .leading)
            ProgressView(value: value)
                .tint(color)
            Text(String(format: "%.0f%%", value * 100))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 30, alignment: .trailing)
        }
    }
}
