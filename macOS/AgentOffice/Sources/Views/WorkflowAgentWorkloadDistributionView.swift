// WorkflowAgentWorkloadDistributionView.swift
import SwiftUI

struct WorkflowAgentWorkloadDistributionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let distribution: [(String, Int, Color)] = [
        ("Architect", 49, .blue),
        ("Builder", 82, .green),
        ("Reviewer", 67, .orange),
        ("Tester", 54, .purple),
        ("Planner", 38, .cyan),
        ("Security", 23, .red),
    ]

    private let total = 313

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workload Distribution").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Total
            HStack {
                Text("Total Tasks")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(total)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(distribution.indices, id: \.self) { i in
                        WorkloadDistRow(
                            agent: distribution[i].0,
                            count: distribution[i].1,
                            percentage: Double(distribution[i].1) / Double(total) * 100,
                            color: distribution[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            // Pie chart representation
            HStack(spacing: 16) {
                ForEach(distribution.indices, id: \.self) { i in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(distribution[i].2)
                            .frame(width: 20, height: 20)
                        Text(distribution[i].0)
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                        Text("\(distribution[i].1)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(distribution[i].2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 480)
    }
}

// MARK: - Workload Distribution Row
struct WorkloadDistRow: View {
    let agent: String
    let count: Int
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(agent)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text("\(count)")
                    .font(.system(size: 11, design: .monospaced))
                Text(String(format: "%.1f%%", percentage))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: percentage / 100.0)
                .tint(color)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}