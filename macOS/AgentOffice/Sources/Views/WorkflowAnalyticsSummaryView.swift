// WorkflowAnalyticsSummaryView.swift
import SwiftUI

struct WorkflowAnalyticsSummaryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Analytics Summary").font(.headline)
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
                    // Key metrics
                    HStack(spacing: 12) {
                        AnalyticsCard(title: "Total Runs", value: "\(Int.random(in: 50...200))", icon: "play.circle.fill", color: .blue)
                        AnalyticsCard(title: "Success Rate", value: "\(Int.random(in: 85...98))%", icon: "checkmark.circle.fill", color: .green)
                        AnalyticsCard(title: "Avg Tokens", value: "\(Int.random(in: 800...1500))", icon: "text.word.spacing", color: .orange)
                    }

                    // Usage breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Usage by Mode").font(.system(size: 12, weight: .semibold))
                        ForEach(WorkflowMode.allCases.prefix(5), id: \.self) { mode in
                            HStack {
                                Text(mode.rawValue.capitalized)
                                    .font(.system(size: 10))
                                Spacer()
                                let percent = Double.random(in: 5...30)
                                ProgressView(value: percent / 100)
                                    .frame(width: 60)
                                Text(String(format: "%.0f%%", percent))
                                    .font(.system(size: 9, design: .monospaced))
                                    .frame(width: 30, alignment: .trailing)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Time analysis
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time Analysis").font(.system(size: 12, weight: .semibold))
                        HStack {
                            Text("Avg response time:")
                            Spacer()
                            Text("\(String(format: "%.1f", Double.random(in: 1...3)))s")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        HStack {
                            Text("Total tokens used:")
                            Spacer()
                            Text("\(Int.random(in: 50000...200000))")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        HStack {
                            Text("Total cost:")
                            Spacer()
                            Text(String(format: "$%.2f", Double.random(in: 1...10)))
                                .font(.system(size: 11, design: .monospaced))
                        }
                    }
                    .font(.system(size: 11))
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

// MARK: - Analytics Card
struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
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
