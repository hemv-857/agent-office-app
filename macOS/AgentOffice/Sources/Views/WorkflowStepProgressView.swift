// WorkflowStepProgressView.swift
import SwiftUI

struct WorkflowStepProgressView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let steps: [(String, StepStatus)] = [
        ("Initialize", .completed),
        ("Load agents", .completed),
        ("Analyze prompt", .completed),
        ("Execute parallel", .running),
        ("Collect results", .pending),
        ("Synthesize output", .pending),
        ("Generate report", .pending),
    ]

    enum StepStatus {
        case completed, running, pending, failed

        var color: Color {
            switch self {
            case .completed: return .green
            case .running: return .blue
            case .pending: return .gray
            case .failed: return .red
            }
        }

        var icon: String {
            switch self {
            case .completed: return "checkmark.circle.fill"
            case .running: return "arrow.triangle.2.circlepath"
            case .pending: return "circle"
            case .failed: return "xmark.circle.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Progress").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 12) {
                            Image(systemName: step.1.icon)
                                .foregroundStyle(step.1.color)
                                .font(.system(size: 14))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.0)
                                    .font(.system(size: 11, weight: step.1 == .running ? .semibold : .regular))
                                if step.1 == .running {
                                    Text("In progress...")
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if step.1 == .running {
                                ProgressView()
                                    .controlSize(.mini)
                            }
                        }
                        .padding(.vertical, 6)

                        if index < steps.count - 1 {
                            HStack {
                                Rectangle()
                                    .fill(step.1 == .completed ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                                    .frame(width: 2, height: 16)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Progress: \(steps.filter { $0.1 == .completed }.count)/\(steps.count) steps")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 420)
    }
}
