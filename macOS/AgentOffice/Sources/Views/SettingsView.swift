// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            Form {
                Section("Provider") {
                    Picker("Provider", selection: $store.selectedProvider) {
                        ForEach(LLMProvider.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    .onChange(of: store.selectedProvider) { _ in store.persist() }

                    SecureField("API Key", text: $store.apiKey)
                        .onChange(of: store.apiKey) { _ in store.persist() }

                    TextField("Model", text: $store.selectedModel)
                }

                Section("Budget") {
                    HStack {
                        Text("Daily budget: $")
                        TextField("10.00", text: Binding(
                            get: { String(format: "%.2f", store.dailyBudget) },
                            set: { store.dailyBudget = Double($0) ?? 10.0 }
                        ))
                        .frame(width: 80)
                    }
                    let remaining = store.dailyBudget - store.todayCost
                    Text("Remaining: $\(String(format: "%.2f", max(0, remaining)))")
                        .foregroundStyle(remaining < 2 ? .red : .secondary)
                }

                Section("Appearance") {
                    Picker("Theme", selection: $store.theme) {
                        ForEach(Theme.allCases, id: \.self) { t in
                            Text(t.rawValue.capitalized).tag(t)
                        }
                    }
                }

                Section("Context Window") {
                    HStack {
                        Text("Max tokens:")
                        TextField("200000", text: Binding(
                            get: { String(store.contextWindow.maxTokens) },
                            set: { store.contextWindow.maxTokens = Int($0) ?? 200_000 }
                        ))
                        .frame(width: 100)
                    }
                    ProgressView(value: store.contextWindow.utilization)
                    Text("\(store.contextWindow.usedTokens) / \(store.contextWindow.maxTokens) tokens used")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("Data") {
                    Button("Clear all cost history") { store.costHistory = []; store.persist() }
                    Button("Clear all session notes") { store.sessionNotes = []; store.persist() }
                    Button("Clear all agent memory") { store.agentMemory = []; store.persist() }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 480, height: 520)
    }
}
