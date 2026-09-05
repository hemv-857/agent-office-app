// WorkflowUsageStatisticsView.swift
import SwiftUI

struct WorkflowUsageStatisticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Usage Statistics").font(.headline)
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
                    // Summary
                    HStack(spacing: 12) {
                        UsageStatCard(title: "Total Runs", value: "\(Int.random(in: 50...200))", color: .blue)
                        UsageStatCard(title: "Total Tokens", value: "\(Int.random(in: 50000...200000))", color: .green)
                        UsageStatCard(title: "Total Cost", value: String(format: "$%.2f", Double.random(in: 1...20)), color: .orange)
                    }

                    // Daily usage
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Usage (Last 7 Days)").font(.system(size: 12, weight: .semibold))
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(0..<7) { i in
                                VStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.accentColor.opacity(Double.random(in: 0.3...1.0)))
                                        .frame(height: CGFloat.random(in: 20...80))
                                    Text(["M", "T", "W", "T", "F", "S", "S"][i])
                                        .font(.system(size: 8))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 100)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Top agents
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Agents").font(.system(size: 12, weight: .semibold))
                        ForEach(0..<3) { i in
                            HStack {
                                Text("\(i + 1)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .frame(width: 16)
                                Text(store.allAgents[i % store.allAgents.count].emoji)
                                Text(store.allAgents[i % store.allAgents.count].name)
                                    .font(.system(size: 11))
                                Spacer()
                                Text("\(Int.random(in: 10...50)) runs")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
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
        .frame(width: 450, height: 480)
    }
}

// MARK: - Usage Stat Card
struct UsageStatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
