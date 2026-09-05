// AgentPerformanceTrendView.swift
import SwiftUI

struct AgentPerformanceTrendView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let values: [Double] = [0.65, 0.72, 0.58, 0.85, 0.78, 0.92, 0.68]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Trend").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Chart
            VStack(spacing: 8) {
                // Y-axis labels + line chart
                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(Array(stride(from: 1.0, through: 0, by: -0.25)), id: \.self) { value in
                            Text(String(format: "%.0f%%", value * 100))
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(height: 30)
                        }
                    }
                    .frame(width: 35)

                    // Line chart
                    Path { path in
                        let width = 300.0
                        let height = 150.0
                        let stepX = width / Double(days.count - 1)

                        for (i, value) in values.enumerated() {
                            let x = Double(i) * stepX
                            let y = height - (value * height)
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.accentColor, lineWidth: 2)
                    .frame(width: 300, height: 150)
                }

                // X-axis labels
                HStack {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 335)

                // Summary
                HStack(spacing: 16) {
                    TrendStat(label: "Avg", value: String(format: "%.0f%%", values.reduce(0, +) / Double(values.count) * 100))
                    TrendStat(label: "Peak", value: String(format: "%.0f%%", (values.max() ?? 0) * 100))
                    TrendStat(label: "Low", value: String(format: "%.0f%%", (values.min() ?? 0) * 100))
                }
                .padding(.top, 8)
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
        .frame(width: 480, height: 380)
    }
}

// MARK: - Trend Stat
struct TrendStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}
