// WorkflowAgentCollaborationRulesView.swift
import SwiftUI

struct WorkflowAgentCollaborationRulesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var rules: [(String, String, String, Bool)] = [
        ("Architect → Builder", "Architect must approve design before Builder starts", "design_approval", true),
        ("Builder → Reviewer", "All code must be reviewed before merge", "code_review", true),
        ("Reviewer → Tester", "Tests run after review passes", "test_after_review", true),
        ("Tester → Planner", "Failed tests notify Planner for re-prioritization", "test_failure_notify", true),
        ("Security → Builder", "Security scans run on every PR", "security_scan", false),
        ("Planner → Architect", "New requirements trigger architecture review", "requirement_review", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Collaboration Rules").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            List {
                ForEach(rules.indices, id: \.self) { i in
                    CollaborationRuleRow(
                        flow: rules[i].0,
                        rule: rules[i].1,
                        enabled: rules[i].3,
                        onToggle: { rules[i].3.toggle() }
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Add Rule") {
                    store.showToast("Rule added", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Collaboration Rule Row
struct CollaborationRuleRow: View {
    let flow: String
    let rule: String
    let enabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(flow)
                    .font(.system(size: 11, weight: .semibold))
                Text(rule)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(get: { enabled }, set: { _ in onToggle() }))
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
