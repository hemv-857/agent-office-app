// WorkflowAgentAgentPerformanceHeatmapView.swift
import SwiftUI

struct WorkflowAgentAgentPerformanceHeatmapView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let hours = ["00-04", "04-08", "08-12", "12-16", "16-20", "20-24"]

    @State private var heatmap: [[Double]] = []

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

            // Legend
            HStack(spacing: 16) {
                Text("Low")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                HStack(spacing: 0) {
                    ForEach(0..<10) { i in
                        Rectangle()
                            .fill(Color(hue: Double(i) * 0.1, saturation: 0.8, brightness: 0.9))
                            .frame(width: 20, height: 12)
                    }
                }
                Text("High")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Heatmap
            ScrollView {
                VStack(spacing: 1) {
                    // Header
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: 70, alignment: .leading)
                        ForEach(hours, id: \.self) { hour in
                            Text(hour)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(width: 55)
                        }
                    }
                    .padding(.horizontal)

                    ForEach(agents.indices, id: \.self) { i in
                        HeatmapRow(
                            agent: agents[i],
                            values: heatmap[i],
                            hours: hours
                        )
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                Button("Refresh") { generateHeatmap() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 460)
        .onAppear { generateHeatmap() }
    }

    private func generateHeatmap() {
        heatmap = agents.map { _ in hours.map { _ in Double.random(in: 0...1) } }
    }
}

// MARK: - Heatmap Row
struct HeatmapRow: View {
    let agent: String
    let values: [Double]
    let hours: [String]

    var body: some View {
        HStack(spacing: 0) {
            Text(agent)
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            ForEach(values.indices, id: \.self) { j in
                let value = values[j]
                ZStack {
                    Rectangle()
                        .fill(Color(hue: value * 0.4, saturation: 0.7, brightness: 0.85))
                        .frame(width: 55, height: 24)
                    Text(String(format: "%.0f%%", value * 100))
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(value > 0.6 ? .white : .primary)
                }
                .frame(width: 55)
            }
        }
    }
}