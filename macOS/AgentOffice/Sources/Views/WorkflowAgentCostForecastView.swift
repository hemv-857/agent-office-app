// WorkflowAgentCostForecastView.swift
import SwiftUI

struct WorkflowAgentCostForecastView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let months: [(String, Double, Double)] = [
        ("Aug 2026", 12.50, 14.20),
        ("Sep 2026", 14.20, 16.80),
        ("Oct 2026", 16.80, 19.50),
        ("Nov 2026", 19.50, 22.10),
        ("Dec 2026", 22.10, 25.80),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Forecast").font(.headline)
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
                    Text("$12.50")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Current")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("$25.80")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Projected")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("+106%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                    Text("Growth")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(months.indices, id: \.self) { i in
                        CostForecastRow(
                            month: months[i].0,
                            actual: i < 2 ? months[i].1 : nil,
                            projected: months[i].2
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
        .frame(width: 440, height: 400)
    }
}

// MARK: - Cost Forecast Row
struct CostForecastRow: View {
    let month: String
    let actual: Double?
    let projected: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(month)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 80, alignment: .leading)

            if let actual = actual {
                Text(String(format: "$%.2f", actual))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(width: 60, alignment: .trailing)
            } else {
                Text("—")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
            }

            Text("→")

                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(String(format: "$%.2f", projected))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(actual != nil ? .orange : .red)
                .frame(width: 60, alignment: .trailing)

            ProgressView(value: projected / 30.0)
                .frame(maxWidth: .infinity)
                .tint(projected > 20 ? .red : .orange)
        }
        .padding(.vertical, 4)
    }
}
