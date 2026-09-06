// WorkflowAgentSettingsEditorView.swift
import SwiftUI

struct WorkflowAgentSettingsEditorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var temperature = 0.7
    @State private var maxTokens = 4096
    @State private var dailyBudget = 2.00
    @State private var alertThreshold = 80.0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Editor").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox("Model Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Temperature:")
                                Slider(value: $temperature, in: 0...2, step: 0.1)
                                Text(String(format: "%.1f", temperature))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 30)
                            }
                            HStack {
                                Text("Max Tokens:")
                                Slider(value: Binding(get: { Double(maxTokens) }, set: { maxTokens = Int($0) }), in: 256...8192, step: 256)
                                Text("\(maxTokens)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                        }
                        .padding(8)
                    }

                    GroupBox("Budget Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Daily Budget:")
                                Slider(value: $dailyBudget, in: 0.5...10.0, step: 0.5)
                                Text(String(format: "$%.2f", dailyBudget))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                            HStack {
                                Text("Alert Threshold:")
                                Slider(value: $alertThreshold, in: 50...95, step: 5)
                                Text(String(format: "%.0f%%", alertThreshold))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                        }
                        .padding(8)
                    }

                    GroupBox("Behavior") {
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle("Streaming responses", isOn: .constant(true))
                            Toggle("Cache responses", isOn: .constant(true))
                            Toggle("Auto-select model", isOn: .constant(false))
                            Toggle("Error recovery", isOn: .constant(true))
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Save") {
                    store.showToast("Settings saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}
