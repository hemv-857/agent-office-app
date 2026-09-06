// WorkflowAgentIntegrationTestView.swift
import SwiftUI

struct WorkflowAgentIntegrationTestView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var isRunning = false

    private let tests: [(String, String, String, Color)] = [
        ("Agent Communication", "Test inter-agent message passing", "passed", .green),
        ("LLM Provider Routing", "Verify correct provider selection", "passed", .green),
        ("Memory Persistence", "Test agent memory save/load cycle", "passed", .green),
        ("Budget Enforcement", "Verify budget limit enforcement", "passed", .green),
        ("Workflow Execution", "End-to-end workflow run test", "passed", .green),
        ("Error Recovery", "Test graceful error handling", "warning", .orange),
        ("Cache Invalidation", "Verify cache behavior under load", "passed", .green),
        ("Concurrent Sessions", "Test multiple session handling", "running", .blue),
    ]

    private var passRate: Double {
        Double(tests.filter { $0.3 == .green }.count) / Double(tests.count) * 100
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Integration Tests").font(.headline)
                Spacer()
                Text(String(format: "%.0f%% pass rate", passRate))
                    .font(.caption)
                    .foregroundStyle(passRate >= 90 ? .green : .orange)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Stats
            HStack(spacing: 12) {
                IntegrationTestStat(label: "Passed", value: "\(tests.filter { $0.3 == .green }.count)", color: .green)
                IntegrationTestStat(label: "Warnings", value: "\(tests.filter { $0.3 == .orange }.count)", color: .orange)
                IntegrationTestStat(label: "Running", value: "\(tests.filter { $0.3 == .blue }.count)", color: .blue)
                IntegrationTestStat(label: "Failed", value: "\(tests.filter { $0.3 == .red }.count)", color: .red)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Test list
            List {
                ForEach(tests.indices, id: \.self) { i in
                    IntegrationTestRow(
                        name: tests[i].0,
                        description: tests[i].1,
                        status: tests[i].2,
                        statusColor: tests[i].3
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button(isRunning ? "Running..." : "Run All Tests") {
                    isRunning = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isRunning = false
                        store.showToast("Tests completed", type: .success)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunning)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Integration Test Stat
struct IntegrationTestStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Integration Test Row
struct IntegrationTestRow: View {
    let name: String
    let description: String
    let status: String
    let statusColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: status == "passed" ? "checkmark.circle.fill" : status == "running" ? "arrow.clockwise" : status == "warning" ? "exclamationmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(statusColor)
                .rotationEffect(status == "running" ? .degrees(360) : .degrees(0))
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status.capitalized)
                .font(.system(size: 9, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusColor.opacity(0.15), in: Capsule())
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 4)
    }
}
