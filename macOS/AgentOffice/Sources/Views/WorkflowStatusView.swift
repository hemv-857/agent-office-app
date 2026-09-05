// WorkflowStatusView.swift
import SwiftUI

struct WorkflowStatusView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Status").font(.headline)
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
                    // Current status
                    VStack(spacing: 8) {
                        HStack {
                            Circle()
                                .fill(store.isRunning ? .green : .gray)
                                .frame(width: 8, height: 8)
                            Text(store.isRunning ? "Running" : "Idle")
                                .font(.system(size: 12, weight: .semibold))
                            Spacer()
                        }

                    if store.isRunning {
                        ProgressView()
                            .controlSize(.small)
                        HStack {
                            Text("Running...")
                                .font(.system(size: 10))
                            Spacer()
                        }
                        .foregroundStyle(.secondary)
                    }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Mode
                    HStack {
                        Text("Mode:")
                        Spacer()
                        Text(store.workflowMode.rawValue.capitalized)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1), in: Capsule())
                            .foregroundStyle(.blue)
                    }
                    .font(.system(size: 11))

                    // Agents
                    HStack {
                        Text("Active Agents:")
                        Spacer()
                        Text("\(store.desks.filter { $0.isOccupied }.count)")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .font(.system(size: 11))

                    // Results
                    HStack {
                        Text("Results:")
                        Spacer()
                        Text("\(store.results.count)")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .font(.system(size: 11))
                }
                .padding()
            }

            Divider()

            HStack {
                if store.isRunning {
                    Button("Cancel") {
                        store.cancelRun()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 380, height: 380)
    }
}
