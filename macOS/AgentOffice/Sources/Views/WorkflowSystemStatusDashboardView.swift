// WorkflowSystemStatusDashboardView.swift
import SwiftUI

struct WorkflowSystemStatusDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var isRefreshing = false

    private let services: [(String, String, String, Color)] = [
        ("Anthropic API", "Connected", "claude-3.5-sonnet", .green),
        ("OpenAI API", "Connected", "gpt-4o", .green),
        ("Ollama", "Running", "localhost:11434", .green),
        ("Cache", "Active", "68% hit rate", .green),
        ("Memory", "OK", "240 MB used", .blue),
        ("Storage", "OK", "6.7 MB / 50 MB", .blue),
    ]

    private let metrics: [(String, String, String)] = [
        ("Uptime", "4h 23m", "Since last restart"),
        ("API Calls Today", "47", "Across 3 providers"),
        ("Total Tokens", "128K", "Input + output"),
        ("Cost Today", "$0.84", "42% of daily budget"),
        ("Active Sessions", "3", "Running workflows"),
        ("Queue Depth", "0", "No pending tasks"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("System Status").font(.headline)
                    HStack(spacing: 4) {
                        Circle().fill(.green).frame(width: 6, height: 6)
                        Text("All systems operational")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                    }
                }
                Spacer()
                Button(action: { refresh() }) {
                    Image(systemName: isRefreshing ? "arrow.clockwise" : "arrow.clockwise")
                        .rotationEffect(isRefreshing ? .degrees(360) : .degrees(0))
                }
                .buttonStyle(.plain)
                .disabled(isRefreshing)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 14) {
                    // Services
                    GroupBox("Services") {
                        VStack(spacing: 6) {
                            ForEach(services.indices, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(services[i].3)
                                        .frame(width: 8, height: 8)
                                    Text(services[i].0)
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    Text(services[i].1)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                    Text(services[i].2)
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(.quaternary, in: Capsule())
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Metrics
                    GroupBox("System Metrics") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(metrics.indices, id: \.self) { i in
                                SystemMetricCard(
                                    label: metrics[i].0,
                                    value: metrics[i].1,
                                    detail: metrics[i].2
                                )
                            }
                        }
                        .padding(8)
                    }

                    // Quick actions
                    GroupBox("Quick Actions") {
                        HStack(spacing: 8) {
                            Button("Restart Ollama") {}
                            Button("Clear Cache") {
                                CacheManager.shared.clear()
                                store.showToast("Cache cleared", type: .success)
                            }
                            Button("Export Logs") {}
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

    private func refresh() {
        isRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRefreshing = false
            store.showToast("System status refreshed", type: .success)
        }
    }
}

// MARK: - System Metric Card
struct SystemMetricCard: View {
    let label: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 10, weight: .medium))
            Text(detail)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
