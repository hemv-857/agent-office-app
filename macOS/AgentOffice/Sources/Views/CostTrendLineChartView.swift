// CostTrendLineChartView.swift
import SwiftUI

struct CostTrendLineChartView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let data: [(String, Double)] = [
        ("Mon", 2.5), ("Tue", 3.8), ("Wed", 1.2), ("Thu", 4.5), ("Fri", 3.2), ("Sat", 0.8), ("Sun", 1.5)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Trend").font(.headline)
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
                // Y-axis labels + chart
                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(Array(stride(from: 5.0, through: 0, by: -1.0)), id: \.self) { value in
                            Text(String(format: "$%.0f", value))
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(height: 30)
                        }
                    }
                    .frame(width: 30)

                    // Bars
                    VStack(spacing: 0) {
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(data, id: \.0) { item in
                                VStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.accentColor.opacity(0.7))
                                        .frame(height: max(4, item.1 / 5.0 * 150))
                                    Text(item.0)
                                        .font(.system(size: 8))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 160)
                    }
                }

                // Summary
                HStack(spacing: 16) {
                    VStack {
                        Text("Total")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.2f", data.reduce(0) { $0 + $1.1 }))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    VStack {
                        Text("Average")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.2f", data.reduce(0) { $0 + $1.1 } / Double(data.count)))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    VStack {
                        Text("Peak")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.2f", data.map(\.1).max() ?? 0))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    VStack {
                        Text("Low")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.2f", data.map(\.1).min() ?? 0))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
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
        .frame(width: 500, height: 380)
    }
}
