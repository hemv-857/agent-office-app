// WorkflowAgentSessionComparisonView.swift
import SwiftUI

struct WorkflowAgentSessionComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var session1 = 0
    @State private var session2 = 1

    private let sessions = ["Session A (Today)", "Session B (Yesterday)", "Session C (2 days ago)"]

    private let metrics: [(String, String, String)] = [
        ("Duration", "2h 15m", "1h 45m"),
        ("Tasks Completed", "12", "8"),
        ("API Calls", "47", "32"),
        ("Total Cost", "$0.84", "$0.62"),
        ("Success Rate", "94.2%", "91.7%"),
        ("Avg Response Time", "2.1s", "2.4s"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Comparison").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Session pickers
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session A")
                        .font(.system(size: 10, weight: .semibold))
                    Picker("", selection: $session1) {
                        ForEach(sessions.indices, id: \.self) { i in
                            Text(sessions[i]).tag(i)
                        }
                    }
                    .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session B")
                        .font(.system(size: 10, weight: .semibold))
                    Picker("", selection: $session2) {
                        ForEach(sessions.indices, id: \.self) { i in
                            Text(sessions[i]).tag(i)
                        }
                    }
                    .labelsHidden()
                }
            }
            .padding()

            // Metrics comparison
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(metrics.indices, id: \.self) { i in
                        ComparisonMetricRow(
                            label: metrics[i].0,
                            value1: metrics[i].1,
                            value2: metrics[i].2
                        )
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
        .frame(width: 480, height: 480)
    }
}

// MARK: - Comparison Metric Row
struct ComparisonMetricRow: View {
    let label: String
    let value1: String
    let value2: String

    var body: some View {
        HStack(spacing: 12) {
            Text(value1)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .frame(width: 80, alignment: .trailing)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .frame(maxWidth: .infinity)
            Text(value2)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .frame(width: 80, alignment: .leading)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
