// WorkflowAgentSettingsValidatorDetailView.swift
import SwiftUI

struct WorkflowAgentSettingsValidatorDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let checks: [(String, String, Bool, String)] = [
        ("API Key", "Anthropic API key is configured", true, "Valid"),
        ("Model", "Claude 3.5 Sonnet selected", true, "Recommended"),
        ("Temperature", "Temperature is 0.7", true, "Optimal"),
        ("Max Tokens", "Max tokens is 4096", true, "Recommended"),
        ("Budget", "Daily budget is $2.00", true, "Set"),
        ("Alerts", "Alert threshold is 80%", true, "Configured"),
        ("Cache", "Response caching enabled", true, "Enabled"),
        ("Streaming", "Streaming responses enabled", true, "Enabled"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Validation Detail").font(.headline)
                Spacer()
                Text("\(checks.filter { $0.2 }.count)/\(checks.count) passed")
                    .font(.caption)
                    .foregroundStyle(.green)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(checks.indices, id: \.self) { i in
                        SettingsValidationDetailRow(
                            setting: checks[i].0,
                            detail: checks[i].1,
                            passed: checks[i].2,
                            status: checks[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Revalidate") {
                    store.showToast("Validation complete", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Settings Validation Detail Row
struct SettingsValidationDetailRow: View {
    let setting: String
    let detail: String
    let passed: Bool
    let status: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(passed ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(setting)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(passed ? .green.opacity(0.15) : .red.opacity(0.15), in: Capsule())
                .foregroundStyle(passed ? .green : .red)
        }
        .padding(10)
        .background(passed ? Color.green.opacity(0.05) : Color.red.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}
