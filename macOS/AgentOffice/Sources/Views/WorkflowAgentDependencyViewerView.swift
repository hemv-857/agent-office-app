// WorkflowAgentDependencyViewerView.swift
import SwiftUI

struct WorkflowAgentDependencyViewerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let dependencies: [(String, String, String)] = [
        ("Architect", "Builder", "Design specs"),
        ("Builder", "Reviewer", "Code for review"),
        ("Reviewer", "Tester", "Approved code"),
        ("Tester", "Planner", "Test results"),
        ("Planner", "Architect", "Requirements"),
        ("Security", "Builder", "Security checks"),
        ("Security", "Reviewer", "Audit findings"),
    ]

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Dependencies").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Dependency graph
                    GroupBox("Dependency Flow") {
                        VStack(spacing: 6) {
                            ForEach(dependencies.indices, id: \.self) { i in
                                HStack(spacing: 8) {
                                    Text(dependencies[i].0)
                                        .font(.system(size: 11, weight: .medium))
                                        .frame(width: 70, alignment: .trailing)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                    Text(dependencies[i].1)
                                        .font(.system(size: 11, weight: .medium))
                                        .frame(width: 70, alignment: .leading)
                                    Text(dependencies[i].2)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.quaternary, in: Capsule())
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Summary
                    GroupBox("Summary") {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("\(dependencies.count)")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                Text("Dependencies")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            VStack(spacing: 4) {
                                Text("\(agents.count)")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                Text("Agents")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            VStack(spacing: 4) {
                                Text("1")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                Text("Cycle")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}
