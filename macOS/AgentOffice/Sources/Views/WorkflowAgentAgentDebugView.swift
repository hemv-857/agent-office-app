// WorkflowAgentAgentDebugView.swift
import SwiftUI

struct WorkflowAgentAgentDebugView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var logs: [(String, String, String)] = [
        ("10:32:15", "Builder", "Starting API implementation for user-service"),
        ("10:32:16", "Architect", "Design pattern validation passed"),
        ("10:32:18", "Reviewer", "Code review queued for next PR"),
        ("10:32:20", "Tester", "Unit tests generating... 3/12 complete"),
        ("10:32:22", "Builder", "Error: Endpoint /users/:id not found"),
        ("10:32:23", "Architect", "Suggestion: Add /users/:id route"),
        ("10:32:25", "Builder", "Route added, retrying request"),
        ("10:32:27", "Tester", "Test 4/12: POST /users - PASSED"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Debug Console").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filter
            HStack(spacing: 6) {
                Text("Filter:")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                ForEach(["All", "Builder", "Architect", "Reviewer", "Tester"], id: \.self) { agent in
                    Text(agent)
                        .font(.system(size: 9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 6)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(logs.indices, id: \.self) { i in
                        HStack(alignment: .top, spacing: 8) {
                            Text(logs[i].0)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 55, alignment: .leading)
                            Circle()
                                .fill(logs[i].1 == "Builder" ? .blue : logs[i].1 == "Architect" ? .green : logs[i].1 == "Reviewer" ? .orange : .purple)
                                .frame(width: 6, height: 6)
                                .padding(.top, 3)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(logs[i].1)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Text(logs[i].2)
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }

            Divider()

            HStack {
                Button("Copy Logs") {
                    store.showToast("Logs copied", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Clear") { logs.removeAll() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 460)
    }
}
