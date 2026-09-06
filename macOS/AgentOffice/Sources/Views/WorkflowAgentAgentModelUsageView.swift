// WorkflowAgentAgentModelUsageView.swift
import SwiftUI

struct WorkflowAgentAgentModelUsageView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let usage: [(String, String, Int, Double, Double)] = [
        ("Architect", "Claude 3.5 Sonnet", 142, 3200, 12.40),
        ("Builder", "GPT-4o", 289, 3500, 24.80),
        ("Reviewer", "Claude 3.5 Sonnet", 167, 3200, 14.50),
        ("Tester", "GPT-4 Turbo", 98, 2800, 8.20),
        ("Planner", "Claude 3.5 Sonnet", 76, 3200, 6.70),
        ("Security", "GPT-4o", 45, 3500, 3.90),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Model Usage").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("817")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Total Calls")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("$70.50")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Total Cost")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("2")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Models Used")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(usage.indices, id: \.self) { i in
                        ModelUsageRow(
                            agent: usage[i].0,
                            model: usage[i].1,
                            calls: usage[i].2,
                            costPer1k: usage[i].3,
                            totalCost: usage[i].4
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
        .frame(width: 500, height: 440)
    }
}

// MARK: - Model Usage Row
struct ModelUsageRow: View {
    let agent: String
    let model: String
    let calls: Int
    let costPer1k: Double
    let totalCost: Double

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(agent)
                    .font(.system(size: 11, weight: .semibold))
                Text(model)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120, alignment: .leading)

            Text("\(calls)")
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 50, alignment: .trailing)

            Text(String(format: "$%.0f/1k", costPer1k))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)

            ProgressView(value: totalCost / 30.0)
                .frame(width: 80)
                .tint(totalCost > 20 ? .red : .orange)

            Text(String(format: "$%.2f", totalCost))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .frame(width: 55, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}