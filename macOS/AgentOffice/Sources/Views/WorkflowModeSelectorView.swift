// WorkflowModeSelectorView.swift
import SwiftUI

struct WorkflowModeSelectorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedMode: WorkflowMode = .parallel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Workflow Mode").font(.headline)
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
                    ForEach(WorkflowMode.allCases, id: \.self) { mode in
                        ModeOptionRow(
                            mode: mode,
                            isSelected: selectedMode == mode,
                            onTap: { selectedMode = mode }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Apply") {
                    store.workflowMode = selectedMode
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 420, height: 480)
    }
}

// MARK: - Mode Option Row
struct ModeOptionRow: View {
    let mode: WorkflowMode
    let isSelected: Bool
    let onTap: () -> Void

    private var description: String {
        switch mode {
        case .parallel: return "Run all agents simultaneously"
        case .pipeline: return "Chain agent outputs sequentially"
        case .synthesis: return "Merge results into unified output"
        case .review: return "Peer review between agents"
        case .debate: return "Adversarial discussion format"
        case .qualityGate: return "Validate before final output"
        case .pipelineApproval: return "Pipeline with human approval"
        case .conditional: return "Branch based on conditions"
        case .collab: return "Collaborative problem solving"
        case .builder: return "Build and iterate on code"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(isSelected ? Color.accentColor : .clear)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle().stroke(Color.secondary, lineWidth: 1)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium))
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding(10)
            .background(isSelected ? Color.accentColor.opacity(0.1) : .clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
