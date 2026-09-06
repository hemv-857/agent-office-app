// WorkflowAgentPerformanceTrackerView.swift
import SwiftUI

struct WorkflowAgentPerformanceTrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedMetric = "tasks"

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    private let tasksCompleted: [Int] = [24, 48, 32, 18, 12, 8]
    private let successRates: [Double] = [92.8, 88.5, 95.2, 90.1, 85.3, 97.0]
    private let avgResponseTimes: [Double] = [2.3, 1.8, 3.1, 2.0, 1.5, 2.8]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Tracker").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Metric picker
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(["tasks", "success", "response"], id: \.self) { metric in
                        Text(metric == "tasks" ? "Tasks" : metric == "success" ? "Success Rate" : "Response Time")
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedMetric == metric ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedMetric == metric ? .white : .primary)
                            .onTapGesture { selectedMetric = metric }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Chart
            ScrollView {
                VStack(spacing: 8) {
                    GroupBox(selectedMetric == "tasks" ? "Tasks Completed" : selectedMetric == "success" ? "Success Rate" : "Avg Response Time") {
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(agents.indices, id: \.self) { i in
                                VStack(spacing: 4) {
                                    Text(metricValue(for: i))
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.accentColor)
                                        .frame(
                                            width: 36,
                                            height: metricHeight(for: i)
                                        )
                                    Text(agents[i].prefix(4).description)
                                        .font(.system(size: 8))
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(8)
                    }

                    // Rankings
                    GroupBox("Rankings") {
                        VStack(spacing: 4) {
                            ForEach(agents.indices.sorted { metricSortValue($0) > metricSortValue($1) }, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Text("\(agents.indices.sorted { metricSortValue($0) > metricSortValue($1) }.firstIndex(of: i)! + 1)")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .frame(width: 20)
                                    Text(agents[i])
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    Text(metricValue(for: i))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(8)
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

    private func metricValue(for index: Int) -> String {
        switch selectedMetric {
        case "tasks": return "\(tasksCompleted[index])"
        case "success": return String(format: "%.1f%%", successRates[index])
        case "response": return String(format: "%.1fs", avgResponseTimes[index])
        default: return ""
        }
    }

    private func metricHeight(for index: Int) -> CGFloat {
        switch selectedMetric {
        case "tasks": return CGFloat(tasksCompleted[index]) / 48.0 * 150
        case "success": return CGFloat(successRates[index]) / 100.0 * 150
        case "response": return CGFloat(avgResponseTimes[index]) / 3.5 * 150
        default: return 0
        }
    }

    private func metricSortValue(_ index: Int) -> Double {
        switch selectedMetric {
        case "tasks": return Double(tasksCompleted[index])
        case "success": return successRates[index]
        case "response": return -avgResponseTimes[index]
        default: return 0
        }
    }
}
