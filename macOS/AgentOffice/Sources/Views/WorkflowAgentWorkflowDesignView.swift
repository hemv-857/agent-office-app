// WorkflowAgentWorkflowDesignView.swift
import SwiftUI

struct WorkflowAgentWorkflowDesignView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let steps: [(Int, String, String)] = [
        (1, "Plan", "Define requirements and goals"),
        (2, "Design", "Architect system and data flow"),
        (3, "Build", "Implement features iteratively"),
        (4, "Review", "Code review and quality checks"),
        (5, "Test", "Run tests and validate"),
        (6, "Deploy", "Ship to production"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Design").font(.headline)
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
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                Text("\(steps[i].0)")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.blue)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(steps[i].1)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(steps[i].2)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)

                        if i < steps.count - 1 {
                            Rectangle()
                                .fill(.quaternary)
                                .frame(width: 2, height: 20)
                                .padding(.leading, 27)
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Start Workflow") {
                    store.showToast("Workflow started", type: .success)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 460)
    }
}
