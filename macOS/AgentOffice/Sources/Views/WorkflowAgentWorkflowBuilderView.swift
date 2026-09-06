// WorkflowAgentWorkflowBuilderView.swift
import SwiftUI

struct WorkflowAgentWorkflowBuilderView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var workflowName = ""
    @State private var selectedAgents: Set<String> = []
    @State private var selectedMode = "pipeline"

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let modes = ["pipeline", "parallel", "review", "debate"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Builder").font(.headline)
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
                    // Name
                    GroupBox("Workflow Name") {
                        TextField("My Custom Workflow", text: $workflowName)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                    }

                    // Mode
                    GroupBox("Workflow Mode") {
                        HStack(spacing: 8) {
                            ForEach(modes, id: \.self) { mode in
                                Text(mode.capitalized)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedMode == mode ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                                    .foregroundStyle(selectedMode == mode ? .white : .primary)
                                    .onTapGesture { selectedMode = mode }
                            }
                        }
                        .padding(8)
                    }

                    // Agents
                    GroupBox("Select Agents") {
                        VStack(spacing: 6) {
                            ForEach(agents, id: \.self) { agent in
                                HStack {
                                    Circle()
                                        .fill(selectedAgents.contains(agent) ? Color.accentColor : .secondary)
                                        .frame(width: 10, height: 10)
                                    Text(agent)
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    if selectedAgents.contains(agent) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                                .padding(8)
                                .background(selectedAgents.contains(agent) ? Color.accentColor.opacity(0.05) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                                .onTapGesture {
                                    if selectedAgents.contains(agent) {
                                        selectedAgents.remove(agent)
                                    } else {
                                        selectedAgents.insert(agent)
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Preview
                    GroupBox("Preview") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workflowName.isEmpty ? "Untitled Workflow" : workflowName)
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(selectedAgents.count) agents · \(selectedMode)")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(selectedAgents.sorted().joined(separator: " → "))
                                .font(.system(size: 9))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Create Workflow") {
                    store.showToast("Workflow created", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(workflowName.isEmpty || selectedAgents.isEmpty)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}
