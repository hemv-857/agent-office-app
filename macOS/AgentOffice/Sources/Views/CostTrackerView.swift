// CostTrackerView.swift
import SwiftUI

struct CostTrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var totalCost: Double { store.costHistory.reduce(0) { $0 + $1.cost } }
    var totalTokens: Int { store.costHistory.reduce(0) { $0 + $1.tokens } }

    var costByAgent: [(name: String, cost: Double, count: Int)] {
        var dict: [String: (cost: Double, count: Int)] = [:]
        for entry in store.costHistory {
            var v = dict[entry.agentName] ?? (0, 0)
            v.cost += entry.cost
            v.count += 1
            dict[entry.agentName] = v
        }
        return dict.map { (name: $0.key, cost: $0.value.cost, count: $0.value.count) }
            .sorted { $0.cost > $1.cost }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Tracker").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary cards
            HStack(spacing: 12) {
                StatCard(title: "Total Cost", value: String(format: "$%.4f", totalCost), color: .green)
                StatCard(title: "Today", value: String(format: "$%.4f", store.todayCost), color: .blue)
                StatCard(title: "Tokens", value: "\(totalTokens)", color: .purple)
                StatCard(title: "Budget Left", value: String(format: "$%.2f", max(0, store.dailyBudget - store.todayCost)),
                         color: store.dailyBudget - store.todayCost < 2 ? .red : .green)
            }
            .padding()

            Divider()

            // By agent
            List(costByAgent, id: \.name) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name).font(.system(size: 13, weight: .medium))
                        Text("\(item.count) runs").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "$%.4f", item.cost)).font(.system(size: 13, weight: .semibold))
                }
            }
        }
        .frame(width: 500, height: 450)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.system(size: 16, weight: .semibold)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}
