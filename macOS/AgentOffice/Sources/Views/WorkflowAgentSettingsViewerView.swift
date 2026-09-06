// WorkflowAgentSettingsViewerView.swift
import SwiftUI

struct WorkflowAgentSettingsViewerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let settings: [(String, String, String)] = [
        ("Provider", "Anthropic", "api.anthropic.com"),
        ("Model", "Claude 3.5 Sonnet", "claude-3-5-sonnet"),
        ("Temperature", "0.7", "0.0 - 2.0"),
        ("Max Tokens", "4096", "256 - 8192"),
        ("Daily Budget", "$2.00", "$0.50 - $10.00"),
        ("Alert Threshold", "80%", "50% - 95%"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Viewer").font(.headline)
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
                    GroupBox("Current Configuration") {
                        VStack(spacing: 4) {
                            // Header
                            HStack {
                                Text("Setting").font(.system(size: 9, weight: .semibold)).frame(width: 80)
                                Text("Value").font(.system(size: 9, weight: .semibold))
                                Text("Range").font(.system(size: 9, weight: .semibold)).frame(width: 80, alignment: .trailing)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)

                            ForEach(settings.indices, id: \.self) { i in
                                HStack {
                                    Text(settings[i].0)
                                        .font(.system(size: 10, weight: .medium))
                                        .frame(width: 80, alignment: .leading)
                                    Text(settings[i].1)
                                        .font(.system(size: 10, weight: .semibold))
                                    Spacer()
                                    Text(settings[i].2)
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 80, alignment: .trailing)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(4)
                    }

                    // Environment
                    GroupBox("Environment") {
                        VStack(alignment: .leading, spacing: 6) {
                            SettingsViewerRow(label: "Platform", value: "macOS")
                            SettingsViewerRow(label: "Version", value: "1.0.0")
                            SettingsViewerRow(label: "Build", value: "275")
                            SettingsViewerRow(label: "Swift", value: "5.9")
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
        .frame(width: 480, height: 480)
    }
}

// MARK: - Settings Viewer Row
struct SettingsViewerRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
            Spacer()
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}
