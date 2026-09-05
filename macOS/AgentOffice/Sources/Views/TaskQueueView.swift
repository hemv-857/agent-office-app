// TaskQueueView.swift
import SwiftUI

struct TaskQueueView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var queuedTasks: [QueuedTask] = []
    @State private var newTaskPrompt = ""
    @State private var newTaskAgent: Agent?
    @State private var showingAgentPicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task Queue").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Add task
            HStack(spacing: 8) {
                TextField("Task prompt...", text: $newTaskPrompt)
                    .textFieldStyle(.roundedBorder)

                Button(action: { showingAgentPicker = true }) {
                    Text(newTaskAgent?.emoji ?? "🤖")
                }
                .buttonStyle(.bordered)
                .frame(width: 40)

                Button("Add") {
                    addTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTaskPrompt.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Task list
            if queuedTasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.number").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No tasks in queue").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(queuedTasks) { task in
                        TaskRow(task: task) {
                            moveTaskUp(task)
                        } onDelete: {
                            deleteTask(task)
                        } onExecute: {
                            executeTask(task)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Text("\(queuedTasks.count) tasks queued")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Run All") { runAllTasks() }
                    .buttonStyle(.borderedProminent)
                    .disabled(queuedTasks.isEmpty)

                Button("Clear All") { queuedTasks.removeAll() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingAgentPicker) {
            AgentPickerSheet(selectedAgent: $newTaskAgent, title: "Select Agent")
        }
    }

    func addTask() {
        let task = QueuedTask(
            id: UUID().uuidString,
            prompt: newTaskPrompt,
            agentId: newTaskAgent?.id,
            agentName: newTaskAgent?.name ?? "Any",
            status: .pending
        )
        queuedTasks.append(task)
        newTaskPrompt = ""
        newTaskAgent = nil
    }

    func moveTaskUp(_ task: QueuedTask) {
        guard let index = queuedTasks.firstIndex(where: { $0.id == task.id }),
              index > 0 else { return }
        queuedTasks.swapAt(index, index - 1)
    }

    func deleteTask(_ task: QueuedTask) {
        queuedTasks.removeAll { $0.id == task.id }
    }

    func executeTask(_ task: QueuedTask) {
        guard let index = queuedTasks.firstIndex(where: { $0.id == task.id }) else { return }
        queuedTasks[index].status = .running

        Task {
            do {
                let agentId = task.agentId ?? store.allAgents.first?.id ?? ""
                let agent = store.allAgents.first { $0.id == agentId }
                let service = LLMService(provider: store.selectedProvider, apiKey: store.apiKey)
                let response = try await service.execute(
                    systemPrompt: agent?.systemPrompt ?? "You are a helpful assistant.",
                    userMessage: task.prompt
                )
                queuedTasks[index].status = .completed
                queuedTasks[index].result = response.text
            } catch {
                queuedTasks[index].status = .failed
                queuedTasks[index].result = error.localizedDescription
            }
        }
    }

    func runAllTasks() {
        for task in queuedTasks where task.status == .pending {
            executeTask(task)
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: QueuedTask
    let onMoveUp: () -> Void
    let onDelete: () -> Void
    let onExecute: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            statusIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(task.prompt)
                    .font(.system(size: 11))
                    .lineLimit(2)
                HStack {
                    Text(task.agentName)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    if let result = task.result {
                        Text(result.prefix(50))
                            .font(.system(size: 9))
                            .foregroundStyle(task.status == .completed ? .green : .red)
                    }
                }
            }

            Spacer()

            HStack(spacing: 4) {
                if task.status == .pending {
                    Button(action: onMoveUp) {
                        Image(systemName: "arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    var statusIcon: some View {
        switch task.status {
        case .pending:
            Image(systemName: "clock").foregroundStyle(.secondary)
        case .running:
            ProgressView().controlSize(.small)
        case .completed:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        }
    }
}

// MARK: - Models
struct QueuedTask: Identifiable {
    let id: String
    let prompt: String
    let agentId: String?
    let agentName: String
    var status: TaskStatus
    var result: String?

    enum TaskStatus {
        case pending, running, completed, failed
    }
}
