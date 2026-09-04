// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = "general"

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

            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("General").tag("general")
                Text("Provider").tag("provider")
                Text("Budget").tag("budget")
                Text("Advanced").tag("advanced")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Tab content
            ScrollView {
                switch selectedTab {
                case "general": GeneralSettings()
                case "provider": ProviderSettings()
                case "budget": BudgetSettings()
                case "advanced": AdvancedSettings()
                default: GeneralSettings()
                }
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - General Settings
struct GeneralSettings: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Appearance") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Theme", selection: $store.theme) {
                        ForEach(Theme.allCases, id: \.self) { t in
                            Text(t.rawValue.capitalized).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(8)
            }

            GroupBox("Office") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Show sidebar on launch", isOn: $store.showSidebar)
                    Toggle("Show results panel on launch", isOn: $store.showResultsPanel)
                    Toggle("Show onboarding on first launch", isOn: $store.hasSeenOnboarding)
                }
                .padding(8)
            }

            GroupBox("Context Window") {
                VStack(alignment: .leading, spacing: 8) {
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
                .padding(8)
            }
        }
    }
}

// MARK: - Provider Settings
struct ProviderSettings: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("LLM Provider") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Provider", selection: $store.selectedProvider) {
                        ForEach(LLMProvider.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    .onChange(of: store.selectedProvider) { _ in store.persist() }

                    if store.selectedProvider != .ollama {
                        SecureField("API Key", text: $store.apiKey)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: store.apiKey) { _ in store.persist() }
                    }

                    TextField("Model", text: $store.selectedModel)
                        .textFieldStyle(.roundedBorder)

                    if store.selectedProvider == .ollama {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            Text("Ollama runs locally on localhost:11434")
                                .font(.caption)
                        }
                    }
                }
                .padding(8)
            }

            GroupBox("Model Info") {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Provider:").foregroundStyle(.secondary)
                        Spacer()
                        Text(store.selectedProvider.displayName)
                    }
                    HStack {
                        Text("Model:").foregroundStyle(.secondary)
                        Spacer()
                        Text(store.selectedModel)
                    }
                    HStack {
                        Text("API Key:").foregroundStyle(.secondary)
                        Spacer()
                        Text(store.apiKey.isEmpty ? "Not set" : "••••••••\(suffix(store.apiKey))")
                    }
                }
                .font(.system(size: 11))
                .padding(8)
            }
        }
    }

    func suffix(_ key: String) -> String {
        key.count > 4 ? String(key.suffix(4)) : ""
    }
}

// MARK: - Budget Settings
struct BudgetSettings: View {
    @EnvironmentObject var store: AppStore

    var totalCost: Double {
        store.costHistory.reduce(0) { $0 + $1.cost }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Daily Budget") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Budget: $")
                        TextField("10.00", text: Binding(
                            get: { String(format: "%.2f", store.dailyBudget) },
                            set: { store.dailyBudget = Double($0) ?? 10.0 }
                        ))
                        .frame(width: 80)
                    }

                    let remaining = store.dailyBudget - store.todayCost
                    HStack {
                        Text("Remaining:")
                        Text("$\(String(format: "%.2f", max(0, remaining)))")
                            .foregroundStyle(remaining < 2 ? .red : .green)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: min(store.todayCost / max(store.dailyBudget, 0.01), 1.0))
                        .tint(store.todayCost > store.dailyBudget * 0.8 ? .red : .green)
                }
                .padding(8)
            }

            GroupBox("Cost Summary") {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Today's cost:").foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "$%.4f", store.todayCost))
                    }
                    HStack {
                        Text("Total cost:").foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "$%.4f", totalCost))
                    }
                    HStack {
                        Text("Total runs:").foregroundStyle(.secondary)
                        Spacer()
                        Text("\(store.costHistory.count)")
                    }
                }
                .font(.system(size: 11))
                .padding(8)
            }

            GroupBox("Actions") {
                HStack {
                    Button("Clear cost history") {
                        store.costHistory = []
                        store.persist()
                    }
                    Button("Reset daily cost") {
                        // Would need a separate mechanism to track daily reset
                    }
                }
                .padding(8)
            }
        }
    }
}

// MARK: - Advanced Settings
struct AdvancedSettings: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Data Management") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("Clear all session notes") {
                        store.sessionNotes = []
                        store.persist()
                    }
                    Button("Clear all agent memory") {
                        store.agentMemory = []
                        store.persist()
                    }
                    Button("Clear all chat history") {
                        store.chatMessages = [:]
                        store.persist()
                    }
                    Button("Clear all groups") {
                        store.groups = []
                        store.persist()
                    }
                    Button("Clear all presets") {
                        store.presets = []
                        store.persist()
                    }
                    Button("Clear activity log") {
                        store.activityLog = []
                    }
                }
                .padding(8)
            }

            GroupBox("Export") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("Export all data as JSON") {
                        let data = [
                            "groups": store.groups,
                            "presets": store.presets,
                            "sessionNotes": store.sessionNotes,
                            "costHistory": store.costHistory
                        ] as [String: Any]
                        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                           let json = String(data: jsonData, encoding: .utf8) {
                            let panel = NSSavePanel()
                            panel.allowedContentTypes = [.json]
                            panel.nameFieldStringValue = "agent-office-export.json"
                            panel.begin { result in
                                if result == .OK, let url = panel.url {
                                    try? json.write(to: url, atomically: true, encoding: .utf8)
                                }
                            }
                        }
                    }
                }
                .padding(8)
            }

            GroupBox("About") {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Version:").foregroundStyle(.secondary)
                        Spacer()
                        Text("1.0.0")
                    }
                    HStack {
                        Text("Agents loaded:").foregroundStyle(.secondary)
                        Spacer()
                        Text("\(store.allAgents.count)")
                    }
                    HStack {
                        Text("Platform:").foregroundStyle(.secondary)
                        Spacer()
                        Text("macOS 14+")
                    }
                }
                .font(.system(size: 11))
                .padding(8)
            }
        }
    }
}
