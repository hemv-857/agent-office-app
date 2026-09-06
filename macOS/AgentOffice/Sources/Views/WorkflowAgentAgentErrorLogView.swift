// WorkflowAgentAgentErrorLogView.swift
import SwiftUI

struct WorkflowAgentAgentErrorLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let errors: [(String, String, String, String)] = [
        ("10:32:15", "Builder", "Rate limit exceeded", "Retry with backoff"),
        ("10:35:22", "Architect", "Invalid API response", "Fallback to cached data"),
        ("10:41:03", "Reviewer", "Timeout on large file", "Split into chunks"),
        ("10:45:18", "Tester", "Assertion failed", "Investigate flaky test"),
        ("10:50:33", "Security", "CSP violation", "Update headers"),
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
                ForEach(["All", "Critical", "Warning", "Info"], id: \.self) { filter in
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
                        AgentErrorLogRow(
                            time: errors[i].0,
                            agent: errors[i].1,
                            message: errors[i].2,
                            resolution: errors[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export Logs") {
                    store.showToast("Logs exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Clear") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - Error Log Row
struct AgentErrorLogRow: View {
    let time: String
    let agent: String
    let message: String
    let resolution: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(time)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 55, alignment: .leading)
                Text(agent)
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 60, alignment: .leading)
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.red)
            }
            HStack {
                Text("Resolution: ")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Text(resolution)
                    .font(.system(size: 9))
                    .foregroundStyle(.green)
            }
            .padding(.leading, 123)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}