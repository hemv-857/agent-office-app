// WorkflowAgentAgentStorageDetailsView.swift
import SwiftUI

struct WorkflowAgentAgentStorageDetailsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let storage: [(String, String, Double, Color)] = [
        ("Chat History", "12.4 MB", 12.4, .blue),
        ("Agent Memory", "8.7 MB", 8.7, .green),
        ("Session Data", "5.2 MB", 5.2, .orange),
        ("Cache", "3.1 MB", 3.1, .purple),
        ("Logs", "1.8 MB", 1.8, .red),
        ("Backups", "15.6 MB", 15.6, .cyan),
        ("Templates", "0.9 MB", 0.9, .pink),
        ("Exports", "2.3 MB", 2.3, .gray),
    ]

    private let totalMB = 50.0

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

            // Total
            HStack {
                Text("Total Used")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f MB", totalMB))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            ProgressView(value: totalMB / 100.0)
                .padding(.horizontal)
                .tint(totalMB > 80 ? .red : totalMB > 50 ? .orange : .green)

            Divider()

            // Breakdown
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(storage.indices, id: \.self) { i in
                        AgentStorageDetailRow(
                            name: storage[i].0,
                            size: storage[i].1,
                            mb: storage[i].2,
                            color: storage[i].3,
                            percentage: storage[i].2 / totalMB * 100
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Clean Cache") {
                    store.showToast("Cache cleaned", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Optimize") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 460, height: 480)
    }
}

// MARK: - Storage Detail Row
struct AgentStorageDetailRow: View {
    let name: String
    let size: String
    let mb: Double
    let color: Color
    let percentage: Double

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(size)
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 60, alignment: .trailing)
            Text(String(format: "%.1f%%", percentage))
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}