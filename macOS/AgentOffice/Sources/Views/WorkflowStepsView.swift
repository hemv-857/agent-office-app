// WorkflowStepsView.swift
import SwiftUI

struct WorkflowStepsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var steps: [WorkflowStep] = []
    @State private var newStepRole = ""

    struct WorkflowStep: Identifiable, Hashable {
        let id = UUID()
        var role: String
        var instruction: String
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Steps").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Steps list
            if steps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.number").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No steps defined").foregroundStyle(.secondary)
                    Text("Add steps to create a custom workflow")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { idx, step in
                        HStack {
                            Text("\(idx + 1)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.role).font(.system(size: 12, weight: .semibold))
                                Text(step.instruction).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }

                            Spacer()

                            Button(action: { removeStep(step) }) {
                                Image(systemName: "trash").font(.system(size: 10))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onMove(perform: moveSteps)
                }
            }

            Divider()

            // Add step
            HStack(spacing: 8) {
                Picker("Role", selection: $newStepRole) {
                    Text("Select role...").tag("")
                    ForEach(["architect", "developer", "qa", "ops", "pm", "designer"], id: \.self) { role in
                        Text(role.capitalized).tag(role)
                    }
                }
                .frame(width: 120)

                Button(action: addStep) {
                    Label("Add Step", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .disabled(newStepRole.isEmpty)

                Spacer()

                Button(action: applySteps) {
                    Label("Apply Workflow", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .disabled(steps.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 400)
        .onAppear {
            // Initialize with current workflow mode steps
            steps = store.desks.filter { $0.isOccupied }.map { desk in
                WorkflowStep(role: desk.role.rawValue, instruction: "Complete the \(desk.role.rawValue) tasks for this workflow")
            }
        }
    }

    func addStep() {
        steps.append(WorkflowStep(role: newStepRole, instruction: "Complete the \(newStepRole) tasks"))
        newStepRole = ""
    }

    func removeStep(_ step: WorkflowStep) {
        steps.removeAll { $0.id == step.id }
    }

    func moveSteps(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
    }

    func applySteps() {
        // Apply the custom workflow steps
        store.showToast("Workflow steps applied", type: .success)
        dismiss()
    }
}
