// StatusBarView.swift
import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject var store: AppStore

    var totalCost: Double {
        store.results.reduce(0) { $0 + $1.costUsd }
    }

    var totalTokens: Int {
        store.results.reduce(0) { $0 + $1.tokensUsed }
    }

    var body: some View {
        HStack(spacing: 16) {
            Label(store.seatedDisplay, systemImage: "person.2")
            Label(store.selectedProvider.displayName, systemImage: "cpu")

            if totalCost > 0 {
                Label(String(format: "$%.4f", totalCost), systemImage: "dollarsign.circle")
            }

            if totalTokens > 0 {
                Label("\(totalTokens) tokens", systemImage: "text.word.spacing")
            }

            if store.isRunning {
                HStack(spacing: 4) {
                    ProgressView()
                        .controlSize(.mini)
                    Text("Running")
                }
                .foregroundStyle(.blue)
            }

            Spacer()

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
