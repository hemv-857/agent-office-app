// WorkflowAgentSettingsManagerDetailView.swift
import SwiftUI

struct WorkflowAgentSettingsManagerDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let categories: [(String, String, Int)] = [
        ("General", "Basic app settings", 5),
        ("Provider", "LLM provider configuration", 4),
        ("Agents", "Agent behavior settings", 6),
        ("Workflows", "Workflow execution settings", 4),
        ("Data", "Data management settings", 3),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Manager Detail").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(categories.indices, id: \.self) { i in
                        SettingsManagerCategoryRow(
                            name: categories[i].0,
                            description: categories[i].1,
                            settingCount: categories[i].2
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

// MARK: - Settings Manager Category Row
struct SettingsManagerCategoryRow: View {
    let name: String
    let description: String
    let settingCount: Int

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(settingCount) settings")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
