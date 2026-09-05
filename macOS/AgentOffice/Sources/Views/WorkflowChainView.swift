// WorkflowChainView.swift
import SwiftUI

struct WorkflowChainView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var chains: [WorkflowChainBuilder.WorkflowChain] = []
    @State private var showingCreateChain = false
    @State private var newChainName = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Chains").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Chain list
            if chains.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.branch").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No workflow chains").foregroundStyle(.secondary)
                    Text("Create chains for complex multi-step workflows")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(chains) { chain in
                        ChainRow(chain: chain) {
                            startChain(chain)
                        } onDelete: {
                            deleteChain(chain)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Create Chain") { showingCreateChain = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingCreateChain) {
            CreateChainView(name: $newChainName, onSave: createChain)
        }
        .onAppear {
            chains = WorkflowChainBuilder.shared.chains
        }
    }

    func createChain() {
        let chain = WorkflowChainBuilder.shared.createChain(
            name: newChainName,
            steps: [
                ("Step 1", "Initial prompt", .parallel, []),
                ("Step 2", "Follow-up prompt", .pipeline, []),
            ]
        )
        chains = WorkflowChainBuilder.shared.chains
        newChainName = ""
        showingCreateChain = false
    }

    func startChain(_ chain: WorkflowChainBuilder.WorkflowChain) {
        WorkflowChainBuilder.shared.startChain(chain.id)
        store.showToast("Chain started", type: .success)
    }

    func deleteChain(_ chain: WorkflowChainBuilder.WorkflowChain) {
        WorkflowChainBuilder.shared.deleteChain(chain.id)
        chains = WorkflowChainBuilder.shared.chains
    }
}

// MARK: - Chain Row
struct ChainRow: View {
    let chain: WorkflowChainBuilder.WorkflowChain
    let onStart: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chain.name).font(.system(size: 12, weight: .medium))
                    if chain.isActive {
                        Text("Active")
                            .font(.system(size: 9))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 3))
                            .foregroundStyle(.green)
                    }
                }
                Text("\(chain.steps.count) steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Progress bar
                let progress = WorkflowChainBuilder.shared.getChainProgress(chain.id)
                ProgressView(value: Double(progress.completed), total: Double(progress.total))
                    .tint(chain.isActive ? .green : .blue)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onStart) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(chain.isActive)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Create Chain View
struct CreateChainView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Workflow Chain").font(.headline)

            TextField("Chain Name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Create") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
