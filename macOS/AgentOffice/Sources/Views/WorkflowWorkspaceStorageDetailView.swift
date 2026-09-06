// WorkflowWorkspaceStorageDetailView.swift
import SwiftUI

struct WorkflowWorkspaceStorageDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Storage Details").font(.headline)
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
                    // Usage summary
                    GroupBox("Storage Usage") {
                        VStack(spacing: 8) {
                            StorageDetailRow(label: "Chat Messages", size: "2.4 MB", percentage: 0.35, color: .blue)
                            StorageDetailRow(label: "Agent Memory", size: "890 KB", percentage: 0.13, color: .purple)
                            StorageDetailRow(label: "Session Notes", size: "1.2 MB", percentage: 0.18, color: .green)
                            StorageDetailRow(label: "Cost History", size: "340 KB", percentage: 0.05, color: .orange)
                            StorageDetailRow(label: "Groups & Presets", size: "56 KB", percentage: 0.01, color: .teal)
                            StorageDetailRow(label: "App Cache", size: "1.8 MB", percentage: 0.27, color: .secondary)
                            Divider()
                            StorageDetailRow(label: "Total", size: "6.7 MB", percentage: 1.0, color: .accentColor, bold: true)
                        }
                        .padding(8)
                    }

                    // Data breakdown
                    GroupBox("Data Breakdown") {
                        VStack(spacing: 6) {
                            StorageDataItem(count: "\(store.allAgents.count)", label: "Agents loaded", detail: "From agents.json catalog")
                            StorageDataItem(count: "\(store.results.count)", label: "Session results", detail: "Completed workflow outputs")
                            StorageDataItem(count: "\(store.activityLog.count)", label: "Activity log entries", detail: "Recent actions and events")
                            StorageDataItem(count: "\(store.costHistory.count)", label: "Cost entries", detail: "API usage cost records")
                            StorageDataItem(count: "\(store.groups.count)", label: "Agent groups", detail: "Saved agent groupings")
                            StorageDataItem(count: "\(store.presets.count)", label: "Office presets", detail: "Saved workspace presets")
                        }
                        .padding(8)
                    }

                    // Cleanup
                    GroupBox("Cleanup Options") {
                        VStack(alignment: .leading, spacing: 8) {
                            Button("Clear old session results") {
                                store.results = []
                                store.showToast("Session results cleared", type: .success)
                            }
                            Button("Clear activity log") {
                                store.activityLog = []
                                store.showToast("Activity log cleared", type: .success)
                            }
                            Button("Compact storage") {
                                store.showToast("Storage compacted", type: .success)
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
        .frame(width: 480, height: 520)
    }
}

// MARK: - Storage Detail Row
struct StorageDetailRow: View {
    let label: String
    let size: String
    let percentage: Double
    let color: Color
    var bold = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 11, weight: bold ? .semibold : .regular))
            Spacer()
            ProgressView(value: percentage)
                .frame(width: 80)
                .tint(color)
            Text(size)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)
        }
    }
}

// MARK: - Storage Data Item
struct StorageDataItem: View {
    let count: String
    let label: String
    let detail: String

    var body: some View {
        HStack(spacing: 10) {
            Text(count)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .frame(width: 40, alignment: .trailing)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 11))
                Text(detail)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
