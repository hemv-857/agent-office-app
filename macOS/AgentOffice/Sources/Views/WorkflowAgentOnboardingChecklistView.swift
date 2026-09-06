// WorkflowAgentOnboardingChecklistView.swift
import SwiftUI

struct WorkflowAgentOnboardingChecklistView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var completedSteps: Set<Int> = []

    private let steps: [(String, String, String)] = [
        ("Configure API Key", "Set up your LLM provider API key", "key.fill"),
        ("Select Agents", "Choose agents for your workspace", "person.3.fill"),
        ("Set Budget", "Configure daily spending limit", "dollarsign.circle.fill"),
        ("Choose Workflow", "Select default workflow mode", "arrow.triangle.branch"),
        ("Customize Theme", "Personalize your workspace appearance", "paintbrush.fill"),
        ("Learn Shortcuts", "Master keyboard shortcuts", "command"),
        ("Create Groups", "Organize agents into groups", "folder.fill"),
        ("Save Preset", "Save your office configuration", "bookmark.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Onboarding Checklist").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Progress
            VStack(spacing: 8) {
                ProgressView(value: Double(completedSteps.count) / Double(steps.count))
                    .tint(.green)
                Text("\(completedSteps.count)/\(steps.count) completed")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            // Steps
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(steps.indices, id: \.self) { index in
                        OnboardingStepRow(
                            step: index + 1,
                            title: steps[index].0,
                            description: steps[index].1,
                            icon: steps[index].2,
                            isCompleted: completedSteps.contains(index),
                            onToggle: {
                                if completedSteps.contains(index) {
                                    completedSteps.remove(index)
                                } else {
                                    completedSteps.insert(index)
                                }
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                if completedSteps.count == steps.count {
                    Label("All steps completed!", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.green)
                }
                Spacer()
                Button("Skip All") {
                    for i in 0..<steps.count { completedSteps.insert(i) }
                }
                .buttonStyle(.bordered)
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

// MARK: - Onboarding Step Row
struct OnboardingStepRow: View {
    let step: Int
    let title: String
    let description: String
    let icon: String
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(isCompleted ? .green : .accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(step). \(title)")
                    .font(.system(size: 12, weight: isCompleted ? .regular : .medium))
                    .strikethrough(isCompleted)
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(10)
        .background(isCompleted ? Color.green.opacity(0.05) : .clear, in: RoundedRectangle(cornerRadius: 8))
    }
}
