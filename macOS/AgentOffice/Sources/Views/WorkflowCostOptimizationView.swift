// WorkflowCostOptimizationView.swift
import SwiftUI

struct WorkflowCostOptimizationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let tips: [(String, String, String)] = [
        ("Use Smaller Models", "Switch to faster, cheaper models for simple tasks", "arrow.down.circle"),
        ("Batch Prompts", "Combine related prompts to reduce API calls", "square.stack"),
        ("Cache Results", "Reuse previous results when inputs haven't changed", "archivebox"),
        ("Set Token Limits", "Limit max tokens per request to control costs", "number"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Optimization").font(.headline)
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
                    // Potential savings
                    VStack(spacing: 8) {
                        Text("Potential Monthly Savings")
                            .font(.system(size: 12, weight: .semibold))
                        Text("$12.50")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundStyle(.green)
                        Text("by implementing these tips")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                    // Tips
                    VStack(spacing: 8) {
                        ForEach(tips, id: \.0) { tip in
                            OptimizationTipRow(
                                title: tip.0,
                                description: tip.1,
                                icon: tip.2
                            )
                        }
                    }
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
        .frame(width: 420, height: 450)
    }
}

// MARK: - Optimization Tip Row
struct OptimizationTipRow: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.green)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}
