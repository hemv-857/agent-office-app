// WorkflowAgentAPIKeyManagerView.swift
import SwiftUI

struct WorkflowAgentAPIKeyManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var anthropicKey = ""
    @State private var openaiKey = ""
    @State private var showAnthropic = false
    @State private var showOpenAI = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("API Key Manager").font(.headline)
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
                    GroupBox("Anthropic API Key") {
                        HStack {
                            if showAnthropic {
                                TextField("sk-ant-...", text: $anthropicKey)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                SecureField("sk-ant-...", text: $anthropicKey)
                                    .textFieldStyle(.roundedBorder)
                            }
                            Button(action: { showAnthropic.toggle() }) {
                                Image(systemName: showAnthropic ? "eye.slash" : "eye")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                    }

                    GroupBox("OpenAI API Key") {
                        HStack {
                            if showOpenAI {
                                TextField("sk-...", text: $openaiKey)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                SecureField("sk-...", text: $openaiKey)
                                    .textFieldStyle(.roundedBorder)
                            }
                            Button(action: { showOpenAI.toggle() }) {
                                Image(systemName: showOpenAI ? "eye.slash" : "eye")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                    }

                    GroupBox("Status") {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Circle().fill(anthropicKey.isEmpty ? .red : .green).frame(width: 8, height: 8)
                                Text("Anthropic").font(.system(size: 10))
                                Spacer()
                                Text(anthropicKey.isEmpty ? "Not configured" : "Configured").font(.system(size: 9)).foregroundStyle(.secondary)
                            }
                            HStack {
                                Circle().fill(openaiKey.isEmpty ? .red : .green).frame(width: 8, height: 8)
                                Text("OpenAI").font(.system(size: 10))
                                Spacer()
                                Text(openaiKey.isEmpty ? "Not configured" : "Configured").font(.system(size: 9)).foregroundStyle(.secondary)
                            }
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Validate") {
                    store.showToast("Keys validated", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Save") {
                    store.showToast("API keys saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 480, height: 400)
    }
}
