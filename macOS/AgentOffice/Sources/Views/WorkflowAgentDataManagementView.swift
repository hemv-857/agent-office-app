// WorkflowAgentDataManagementView.swift
import SwiftUI

struct WorkflowAgentDataManagementView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let dataItems: [(String, String, String)] = [
        ("Chat History", "12 conversations", "48 KB"),
        ("Agent Config", "6 agents", "2.4 KB"),
        ("Workflow Templates", "8 templates", "3.1 KB"),
        ("Session Notes", "15 notes", "5.6 KB"),
        ("Cost History", "30 days", "1.8 KB"),
        ("Keyboard Shortcuts", "10 shortcuts", "0.8 KB"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Data Management").font(.headline)
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
                Text("Total Size")
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text("61.7 KB")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(dataItems.indices, id: \.self) { i in
                        DataManagementRow(
                            name: dataItems[i].0,
                            count: dataItems[i].1,
                            size: dataItems[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export All") {
                    store.showToast("All data exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 440, height: 440)
    }
}

// MARK: - Data Management Row
struct DataManagementRow: View {
    let name: String
    let count: String
    let size: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.fill")
                .foregroundStyle(.secondary)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(count)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(size)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
