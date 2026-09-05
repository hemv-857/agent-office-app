// WorkflowTemplatePreviewView.swift
import SwiftUI

struct WorkflowTemplatePreviewView: View {
    let template: WorkflowTemplate
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(template.label).font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Template info
                    HStack {
                        Text(template.icon).font(.system(size: 24))
                        VStack(alignment: .leading) {
                            Text(template.label).font(.system(size: 14, weight: .semibold))
                            Text(template.description)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Mode
                    HStack {
                        Text("Mode:").font(.system(size: 11, weight: .semibold))
                        Text(template.workflowMode.rawValue.capitalized)
                            .font(.system(size: 11))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1), in: Capsule())
                            .foregroundStyle(.blue)
                    }

                    // Agent roles
                    if !template.agentRoles.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Agent Roles").font(.system(size: 11, weight: .semibold))
                            ForEach(template.agentRoles, id: \.self) { role in
                                Text(role)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }

                    // Prompt
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prompt").font(.system(size: 11, weight: .semibold))
                        Text(template.prompt)
                            .font(.system(size: 10))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
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
        .frame(width: 450, height: 450)
    }
}
