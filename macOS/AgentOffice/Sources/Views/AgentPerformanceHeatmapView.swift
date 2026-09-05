// AgentPerformanceHeatmapView.swift
import SwiftUI

struct AgentPerformanceHeatmapView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics = ["Speed", "Quality", "Tokens", "Cost", "Success"]
    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Heatmap").font(.headline)
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
                    // Heatmap grid
                    VStack(spacing: 0) {
                        // Header
                        HStack(spacing: 0) {
                            Text("").frame(width: 70)
                            ForEach(metrics, id: \.self) { metric in
                                Text(metric)
                                    .font(.system(size: 8, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom, 4)

                        // Rows
                        ForEach(agents, id: \.self) { agent in
                            HStack(spacing: 0) {
                                Text(agent)
                                    .font(.system(size: 9, weight: .medium))
                                    .frame(width: 70, alignment: .leading)
                                ForEach(metrics, id: \.self) { metric in
                                    let value = Double.random(in: 0.3...1.0)
                                    Rectangle()
                                        .fill(heatColor(value))
                                        .frame(height: 28)
                                        .overlay(
                                            Text(String(format: "%.0f%%", value * 100))
                                                .font(.system(size: 8, design: .monospaced))
                                                .foregroundStyle(.white)
                                        )
                                }
                            }
                        }
                    }

                    // Legend
                    HStack(spacing: 8) {
                        ForEach(0..<5) { i in
                            let value = Double(i) / 4.0
                            Rectangle()
                                .fill(heatColor(value))
                                .frame(width: 20, height: 12)
                            Text(String(format: "%.0f%%", value * 100))
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 8)
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
        .frame(width: 500, height: 400)
    }

    private func heatColor(_ value: Double) -> Color {
        if value > 0.8 { return .green }
        if value > 0.6 { return .yellow }
        if value > 0.4 { return .orange }
        return .red
    }
}
