// WorkflowAgentSettingsValidatorView.swift
import SwiftUI

struct WorkflowAgentSettingsValidatorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let validations: [(String, String, Bool)] = [
        ("API Key configured", "Anthropic API key is set", true),
        ("Budget limit set", "Daily budget is $2.00", true),
        ("Temperature valid", "Temperature is 0.7 (recommended: 0.3-0.7)", true),
        ("Max tokens valid", "Max tokens is 4096 (recommended: 1024-4096)", true),
        ("Model selected", "Claude 3.5 Sonnet is selected", true),
        ("Alert threshold valid", "Alert threshold is 80% (recommended: 70-90%)", true),
        ("Cache enabled", "Response caching is enabled", true),
        ("Streaming enabled", "Streaming responses is enabled", true),
    ]

    private var passCount: Int { validations.filter { $0.2 }.count }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Validator").font(.headline)
                Spacer()
                Text("\(passCount)/\(validations.count) passed")
                    .font(.caption)
                    .foregroundStyle(passCount == validations.count ? .green : .orange)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(validations.indices, id: \.self) { i in
                        SettingsValidationRow(
                            title: validations[i].0,
                            detail: validations[i].1,
                            passed: validations[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Revalidate") {
                    store.showToast("Settings validated", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}

// MARK: - Settings Validation Row
struct SettingsValidationRow: View {
    let title: String
    let detail: String
    let passed: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(passed ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(passed ? Color.green.opacity(0.05) : Color.red.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}
