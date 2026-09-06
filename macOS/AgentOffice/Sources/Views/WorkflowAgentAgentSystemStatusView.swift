// WorkflowAgentAgentSystemStatusView.swift
import SwiftUI

struct WorkflowAgentAgentSystemStatusView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let components: [(String, String, Color, String)] = [
        ("LLM Gateway", "Healthy", .green, "All providers responsive"),
        ("Agent Runtime", "Healthy", .green, "6 agents active"),
        ("Memory Store", "Healthy", .green, "50 MB / 1 GB"),
        ("Cache Layer", "Degraded", .orange, "Hit rate 72%"),
        ("Task Queue", "Healthy", .green, "12 pending"),
        ("Scheduler", "Healthy", .green, "6 jobs scheduled"),
        ("Webhooks", "Healthy", .green, "4 endpoints ok"),
        ("Database", "Healthy", .green, "Connected"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Status").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Overall status
            HStack(spacing: 16) {
                StatusBadge(label: "Overall", status: "Healthy", color: .green)
                StatusBadge(label: "Uptime", status: "99.9%", color: .blue)
                StatusBadge(label: "Incidents", status: "0", color: .green)
                StatusBadge(label: "Last Check", status: "2m ago", color: .secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(components.indices, id: \.self) { i in
                        SystemComponentRow(
                            name: components[i].0,
                            status: components[i].1,
                            color: components[i].2,
                            detail: components[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Run Diagnostics") { }
                    .buttonStyle(.bordered)
                Button("View Logs") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 460)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let label: String
    let status: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(status)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - System Component Row
struct SystemComponentRow: View {
    let name: String
    let status: String
    let color: Color
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(color.opacity(0.15), in: Capsule())
                .foregroundStyle(color)
        }
        .padding(.vertical, 4)
    }
}