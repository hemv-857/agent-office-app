// WorkflowAgentOnboardingProgressView.swift
import SwiftUI

struct WorkflowAgentOnboardingProgressView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var completedSteps: Set<String> = ["welcome", "api_key", "first_agent"]

    private let steps: [(String, String, String, String)] = [
        ("welcome", "Welcome Screen", "Introduction to Agent Office", "Check out the office layout"),
        ("api_key", "Configure API Key", "Set up your LLM provider API key", "Go to Settings → Provider"),
        ("first_agent", "Meet Your First Agent", "Interact with an AI agent at a desk", "Click on any desk in the office"),
        ("custom_agent", "Create Custom Agent", "Build a specialized agent for your needs", "Use the Agent Creator"),
        ("first_workflow", "Run First Workflow", "Execute a workflow with multiple agents", "Try the Pipeline workflow"),
        ("keyboard_shortcuts", "Learn Shortcuts", "Master keyboard shortcuts for speed", "Press ? to see shortcuts"),
        ("export_data", "Export Your Data", "Export chat history and results", "Settings → Data → Export"),
        ("customize_theme", "Customize Theme", "Personalize the look and feel", "Settings → General → Theme"),
    ]

    private var progress: Double {
        Double(completedSteps.count) / Double(steps.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Onboarding Progress").font(.headline)
                Spacer()
                Text("\(completedSteps.count)/\(steps.count) steps")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Progress bar
            VStack(spacing: 6) {
                ProgressView(value: progress)
                    .tint(.accentColor)
                Text("\(Int(progress * 100))% Complete")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Steps
            List {
                ForEach(steps, id: \.0) { step in
                    OnboardingProgressStepRow(
                        id: step.0,
                        title: step.1,
                        description: step.2,
                        detail: step.3,
                        isCompleted: completedSteps.contains(step.0),
                        onToggle: {
                            if completedSteps.contains(step.0) {
                                completedSteps.remove(step.0)
                            } else {
                                completedSteps.insert(step.0)
                            }
                        }
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Skip All") {
                    completedSteps = Set(steps.map { $0.0 })
                    store.showToast("All steps completed!", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Onboarding Progress Step Row
struct OnboardingProgressStepRow: View {
    let id: String
    let title: String
    let description: String
    let detail: String
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .strikethrough(isCompleted)
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(detail)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
