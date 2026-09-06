// WorkflowAgentErrorLogView.swift
import SwiftUI

struct WorkflowAgentErrorLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let errors: [(String, String, String, String, String, Color)] = [
        ("2026-01-15 10:32", "Builder", "High", "Rate limit exceeded", "Retry with exponential backoff", .red),
        ("2026-01-15 10:45", "Architect", "Medium", "Invalid API response format", "Added validation layer", .orange),
        ("2026-01-14 14:22", "Reviewer", "Low", "Typo in comment", "Auto-fixed on commit", .blue),
        ("2026-01-14 16:10", "Tester", "High", "Flaky integration test", "Quarantined, investigating", .red),
        ("2026-01-13 09:30", "Security", "Critical", "CVE-2026-1234 in dependency", "Updated to v2.1.0", .red),
        ("2026-01-13 11:45", "Planner", "Medium", "Sprint overallocation", "Rebalanced assignments", .orange),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Error Log").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filter
            HStack(spacing: 6) {
                ForEach(["All", "Critical", "High", "Medium", "Low"], id: \.self) { filter in
                    Text(filter)
                        .font(.system(size: 9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 6)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(errors.indices, id: \.self) { i in
                        ErrorLogRow(
                            timestamp: errors[i].0,
                            agent: errors[i].1,
                            severity: errors[i].2,
                            message: errors[i].3,
                            resolution: errors[i].4,
                            color: errors[i].5
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Error log exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Clear Resolved") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 560, height: 480)
    }
}

// MARK: - Error Log Row
struct ErrorLogRow: View {
    let timestamp: String
    let agent: String
    let severity: String
    let message: String
    let resolution: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(timestamp)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 100, alignment: .leading)
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(agent)
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 60, alignment: .leading)
                Text(severity)
                    .font(.system(size: 9, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.15), in: Capsule())
                    .foregroundStyle(color)
            }

            Text(message)
                .font(.system(size: 10))
                .padding(.leading, 108)

            HStack {
                Text("Resolution:")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Text(resolution)
                    .font(.system(size: 9))
                    .foregroundStyle(.green)
            }
            .padding(.leading, 108)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}