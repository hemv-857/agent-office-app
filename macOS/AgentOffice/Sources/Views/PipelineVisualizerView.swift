// PipelineVisualizerView.swift
import SwiftUI

struct PipelineVisualizerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Pipeline Visualizer").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if store.pipelineSteps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.branch").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No pipeline running").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(store.pipelineSteps.enumerated()), id: \.element.id) { idx, step in
                            HStack(spacing: 12) {
                                // Step number
                                ZStack {
                                    Circle()
                                        .fill(statusColor(step.status))
                                        .frame(width: 28, height: 28)
                                    Text("\(idx + 1)").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(step.agentName).font(.system(size: 13, weight: .semibold))
                                    Text(step.agentRole).font(.caption).foregroundStyle(.secondary)
                                }

                                Spacer()

                                statusIcon(step.status)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 10)

                            if idx < store.pipelineSteps.count - 1 {
                                HStack {
                                    Spacer().frame(width: 30)
                                    VStack(spacing: 0) {
                                        Rectangle().fill(Color.secondary.opacity(0.2)).frame(width: 2, height: 20)
                                        Image(systemName: "arrow.down").font(.system(size: 8)).foregroundStyle(.secondary)
                                        Rectangle().fill(Color.secondary.opacity(0.2)).frame(width: 2, height: 20)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 400, height: 450)
    }

    func statusColor(_ status: AgentStatus) -> Color {
        switch status {
        case .idle: return .secondary
        case .working: return .blue
        case .done: return .green
        case .error: return .red
        case .blocked: return .orange
        }
    }

    @ViewBuilder
    func statusIcon(_ status: AgentStatus) -> some View {
        switch status {
        case .working: ProgressView().controlSize(.mini)
        case .done: Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .error: Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        default: EmptyView()
        }
    }
}
