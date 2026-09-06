// WorkflowAgentCollaborationRulesView.swift
import SwiftUI

struct WorkflowAgentCollaborationRulesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let rules: [(String, String, String, Bool)] = [
        ("Architect → Builder", "Design handoff required", "Builder must acknowledge design doc", true),
        ("Builder → Reviewer", "PR template enforced", "All fields required before submit", true),
        ("Reviewer → Tester", "Approval triggers tests", "Auto-run integration suite", true),
        ("Tester → Builder", "Failures block merge", "Builder notified immediately", true),
        ("Security → All", "Scan on every PR", "Critical findings block merge", true),
        ("Planner → Architect", "Sprint plan shared", "Architect reviews capacity", false),
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

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(rules.indices, id: \.self) { i in
                        CollabRuleRow(
                            pair: rules[i].0,
                            title: rules[i].1,
                            description: rules[i].2,
                            enabled: rules[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Add Rule") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 440)
    }
}

// MARK: - Collaboration Rule Row
struct CollabRuleRow: View {
    let pair: String
    let title: String
    let description: String
    let enabled: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: enabled ? "checkmark.shield.fill" : "shield")
                .foregroundStyle(enabled ? .green : .secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(pair)
                        .font(.system(size: 10, weight: .semibold))
                    Text(title)
                        .font(.system(size: 10, weight: .medium))
                }
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: .constant(enabled))
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}