// WorkflowSystemRequirementsView.swift
import SwiftUI

struct WorkflowSystemRequirementsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Requirements").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Requirements
                    RequirementRow(label: "macOS", value: "14.0 or later", met: true)
                    RequirementRow(label: "Architecture", value: "Apple Silicon or Intel", met: true)
                    RequirementRow(label: "RAM", value: "4 GB minimum", met: true)
                    RequirementRow(label: "Storage", value: "100 MB available", met: true)
                    RequirementRow(label: "Network", value: "Internet for cloud LLMs", met: true)

                    Divider()

                    // Current system
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your System").font(.system(size: 12, weight: .semibold))
                        RequirementRow(label: "macOS", value: "15.0", met: true)
                        RequirementRow(label: "Architecture", value: "Apple Silicon", met: true)
                        RequirementRow(label: "RAM", value: "16 GB", met: true)
                        RequirementRow(label: "Storage", value: "256 GB available", met: true)
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
        .frame(width: 400, height: 400)
    }
}

// MARK: - Requirement Row
struct RequirementRow: View {
    let label: String
    let value: String
    let met: Bool

    var body: some View {
        HStack {
            Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(met ? .green : .red)
                .font(.system(size: 12))
            Text(label)
                .font(.system(size: 11))
            Spacer()
            Text(value)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}
