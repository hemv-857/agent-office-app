// WorkflowAgentTaskDispatcherView.swift
import SwiftUI

struct WorkflowAgentTaskDispatcherView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var taskTitle = ""
    @State private var selectedAgent = "Builder"
    @State private var priority = "medium"

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let priorities = ["low", "medium", "high", "critical"]

    private let recentDispatches: [(String, String, String, String)] = [
        ("Auth endpoint implementation", "Builder", "high", "2 min ago"),
        ("Code review PR #42", "Reviewer", "medium", "5 min ago"),
        ("Security scan codebase", "Security", "high", "12 min ago"),
        ("Update sprint backlog", "Planner", "low", "20 min ago"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task Dispatcher").font(.headline)
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
                    // New task form
                    GroupBox("Dispatch New Task") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Task title...", text: $taskTitle)
                                .textFieldStyle(.plain)
                                .padding(8)
                                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))

                            HStack(spacing: 8) {
                                Picker("Agent", selection: $selectedAgent) {
                                    ForEach(agents, id: \.self) { Text($0) }
                                }
                                Picker("Priority", selection: $priority) {
                                    ForEach(priorities, id: \.self) { Text($0.capitalized) }
                                }
                            }

                            Button("Dispatch Task") {
                                store.showToast("Task dispatched to \(selectedAgent)", type: .success)
                                taskTitle = ""
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(taskTitle.isEmpty)
                        }
                        .padding(8)
                    }

                    // Recent dispatches
                    GroupBox("Recent Dispatches") {
                        VStack(spacing: 6) {
                            ForEach(recentDispatches.indices, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 6, height: 6)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(recentDispatches[i].0)
                                            .font(.system(size: 11, weight: .medium))
                                        HStack(spacing: 4) {
                                            Text(recentDispatches[i].1)
                                                .font(.system(size: 9))
                                            Text(recentDispatches[i].2)
                                                .font(.system(size: 8))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(.quaternary, in: Capsule())
                                        }
                                    }
                                    Spacer()
                                    Text(recentDispatches[i].3)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                }
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
        .frame(width: 520, height: 520)
    }
}
