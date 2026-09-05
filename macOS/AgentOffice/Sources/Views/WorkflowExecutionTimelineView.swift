// WorkflowExecutionTimelineView.swift
import SwiftUI

struct WorkflowExecutionTimelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let steps: [(String, String, TimelineStatus, TimeInterval)] = [
        ("Initialize", "Setting up agents", .completed, 0.1),
        ("Analyze", "Analyzing prompt", .completed, 1.2),
        ("Execute", "Running agents", .running, 2.5),
        ("Synthesize", "Combining results", .pending, 0),
        ("Review", "Quality check", .pending, 0),
        ("Output", "Final response", .pending, 0),
    ]

    enum TimelineStatus {
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
                Text("Execution Timeline").font(.headline)
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
                        HStack(alignment: .top, spacing: 12) {
                            // Timeline line
                            VStack(spacing: 0) {
                                Image(systemName: step.2.icon)
                                    .foregroundStyle(step.2.color)
                                    .font(.system(size: 16))
                                if index < steps.count - 1 {
                                    Rectangle()
                                        .fill(index < steps.count - 1 ? step.2.color.opacity(0.3) : Color.gray.opacity(0.2))
                                        .frame(width: 2, height: 30)
                                }
                            }
                            .frame(width: 20)

                            // Content
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(step.0)
                                        .font(.system(size: 12, weight: step.2 == .running ? .semibold : .regular))
                                    if step.2 == .running {
                                        ProgressView()
                                            .controlSize(.mini)
                                    }
                                    Spacer()
                                    if step.3 > 0 {
                                        Text(String(format: "%.1fs", step.3))
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Text(step.1)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Stats
            HStack(spacing: 16) {
                Text("Completed: \(steps.filter { $0.2 == .completed }.count)/\(steps.count)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text("Total time: \(String(format: "%.1fs", steps.map(\.3).reduce(0, +)))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 450)
    }
}
