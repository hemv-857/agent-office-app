// WorkflowCostBreakdownByDayView.swift
import SwiftUI

struct WorkflowCostBreakdownByDayView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let dailyData: [(String, Double, Int, Int)] = [
        ("Mon", 1.24, 52, 3),
        ("Tue", 0.98, 41, 2),
        ("Wed", 1.56, 65, 4),
        ("Thu", 2.12, 88, 5),
        ("Fri", 0.84, 35, 2),
        ("Sat", 0.32, 13, 1),
        ("Sun", 0.0, 0, 0),
    ]

    private let maxCost: Double = 2.12

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost by Day").font(.headline)
                Spacer()
                Text(String(format: "$%.2f this week", dailyData.map { $0.1 }.reduce(0, +)))
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Bar chart
                    GroupBox("Daily Cost") {
                        VStack(spacing: 6) {
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(dailyData.indices, id: \.self) { i in
                                    VStack(spacing: 4) {
                                        Text(String(format: "$%.2f", dailyData[i].1))
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(dailyData[i].1 > 1.5 ? Color.red : dailyData[i].1 > 0.5 ? Color.accentColor : Color.accentColor.opacity(0.4))
                                            .frame(
                                                width: 36,
                                                height: maxCost > 0 ? CGFloat(dailyData[i].1 / maxCost) * 120 : 0
                                            )
                                        Text(dailyData[i].0)
                                            .font(.system(size: 9))
                                    }
                                }
                            }
                            .frame(height: 180)

                            // Budget line
                            HStack {
                                Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
                                Text("Daily budget: $1.50")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
                            }
                        }
                        .padding(8)
                    }

                    // Detail table
                    GroupBox("Breakdown") {
                        VStack(spacing: 4) {
                            // Header
                            HStack {
                                Text("Day").font(.system(size: 9, weight: .semibold)).frame(width: 40)
                                Text("Cost").font(.system(size: 9, weight: .semibold)).frame(width: 60, alignment: .trailing)
                                Text("Tokens").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                                Text("Tasks").font(.system(size: 9, weight: .semibold)).frame(width: 40, alignment: .trailing)
                                Text("Status").font(.system(size: 9, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)

                            ForEach(dailyData.indices, id: \.self) { i in
                                HStack {
                                    Text(dailyData[i].0)
                                        .font(.system(size: 10))
                                        .frame(width: 40)
                                    Text(String(format: "$%.2f", dailyData[i].1))
                                        .font(.system(size: 10, design: .monospaced))
                                        .frame(width: 60, alignment: .trailing)
                                    Text("\(dailyData[i].2)")
                                        .font(.system(size: 10, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
                                    Text("\(dailyData[i].3)")
                                        .font(.system(size: 10, design: .monospaced))
                                        .frame(width: 40, alignment: .trailing)
                                    Text(dailyData[i].1 > 1.5 ? "Over" : dailyData[i].1 > 0 ? "OK" : "Idle")
                                        .font(.system(size: 9))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            (dailyData[i].1 > 1.5 ? Color.red : dailyData[i].1 > 0 ? Color.green : Color.secondary)
                                                .opacity(0.15), in: Capsule()
                                        )
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(4)
                    }

                    // Summary
                    HStack(spacing: 16) {
                        CostDayStat(label: "Avg", value: String(format: "$%.2f", dailyData.map { $0.1 }.reduce(0, +) / 7))
                        CostDayStat(label: "Peak", value: String(format: "$%.2f", dailyData.map { $0.1 }.max()!))
                        CostDayStat(label: "Idle Days", value: "\(dailyData.filter { $0.1 == 0 }.count)")
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
        .frame(width: 520, height: 560)
    }
}

// MARK: - Cost Day Stat
struct CostDayStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
