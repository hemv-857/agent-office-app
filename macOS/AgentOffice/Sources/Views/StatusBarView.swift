// StatusBarView.swift
import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject var store: AppStore
    @State private var showCostDetail = false

    var totalCost: Double {
        store.results.reduce(0) { $0 + $1.costUsd }
    }

    var totalTokens: Int {
        store.results.reduce(0) { $0 + $1.tokensUsed }
    }

    var budgetPercent: Double {
        store.dailyBudget > 0 ? (store.todayCost / store.dailyBudget) * 100 : 0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Seated agents
            Label(store.seatedDisplay, systemImage: "person.2")

            // Provider
            Label(store.selectedProvider.displayName, systemImage: "cpu")

            // Context window indicator
            if store.contextWindow.usedTokens > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "square.stack")
                    ProgressView(value: store.contextWindow.utilization)
                        .frame(width: 50)
                    Text("\(Int(store.contextWindow.utilization * 100))%")
                        .font(.system(size: 9, design: .monospaced))
                }
                .help("Context window: \(store.contextWindow.usedTokens) / \(store.contextWindow.maxTokens) tokens")
            }

            // Cost
            if totalCost > 0 {
                Button(action: { showCostDetail.toggle() }) {
                    HStack(spacing: 3) {
                        Image(systemName: "dollarsign.circle")
                        Text(String(format: "$%.4f", totalCost))
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showCostDetail) {
                    CostBreakdownPopover()
                        .environmentObject(store)
                }
            }

            // Tokens
            if totalTokens > 0 {
                Label("\(totalTokens) tokens", systemImage: "text.word.spacing")
            }

            // Budget bar
            if store.todayCost > 0 {
                HStack(spacing: 4) {
                    ProgressView(value: min(budgetPercent, 100), total: 100)
                        .frame(width: 40)
                        .tint(budgetPercent > 80 ? .red : .green)
                    Text(String(format: "$%.2f/$%.2f", store.todayCost, store.dailyBudget))
                        .font(.system(size: 9, design: .monospaced))
                }
                .help("Daily budget: \(String(format: "%.2f%%", budgetPercent)) used")
            }

            // Running indicator
            if store.isRunning {
                HStack(spacing: 4) {
                    ProgressView()
                        .controlSize(.mini)
                    Text("Running")
                }
                .foregroundStyle(.blue)
            }

            Spacer()

            // Version
            Text("v1.0.0")
                .foregroundStyle(.tertiary)
        }
        .font(.system(size: 10))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.background)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

// MARK: - Cost Breakdown Popover
struct CostBreakdownPopover: View {
    @EnvironmentObject var store: AppStore

    var costByAgent: [(name: String, cost: Double, tokens: Int)] {
        var dict: [String: (cost: Double, tokens: Int)] = [:]
        for entry in store.costHistory {
            var v = dict[entry.agentName] ?? (0, 0)
            v.cost += entry.cost
            v.tokens += entry.tokens
            dict[entry.agentName] = v
        }
        return dict.map { (name: $0.key, cost: $0.value.cost, tokens: $0.value.tokens) }
            .sorted { $0.cost > $1.cost }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cost Breakdown").font(.headline)

            if costByAgent.isEmpty {
                Text("No cost data").foregroundStyle(.secondary)
            } else {
                ForEach(costByAgent, id: \.name) { item in
                    HStack {
                        Text(item.name).font(.system(size: 11))
                        Spacer()
                        Text("\(item.tokens)").font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                        Text(String(format: "$%.4f", item.cost))
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.green)
                    }
                }

                Divider()

                HStack {
                    Text("Total").font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(String(format: "$%.4f", costByAgent.reduce(0) { $0 + $1.cost }))
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                }
            }
        }
        .padding(12)
        .frame(width: 280)
    }
}
