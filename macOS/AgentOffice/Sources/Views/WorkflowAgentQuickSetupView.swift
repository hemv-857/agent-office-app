// WorkflowAgentQuickSetupView.swift
import SwiftUI

struct WorkflowAgentQuickSetupView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedPreset = "balanced"

    private let presets: [(String, String, String)] = [
        ("budget", "Budget", "Lowest cost, slower responses"),
        ("balanced", "Balanced", "Good speed and quality"),
        ("premium", "Premium", "Best quality, higher cost"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Setup").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 12) {
                // Preset selector
                GroupBox("Choose Preset") {
                    VStack(spacing: 6) {
                        ForEach(presets, id: \.0) { preset in
                            HStack {
                                Circle()
                                    .fill(selectedPreset == preset.0 ? Color.accentColor : .secondary)
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading) {
                                    Text(preset.1)
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(preset.2)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedPreset == preset.0 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(8)
                            .background(selectedPreset == preset.0 ? Color.accentColor.opacity(0.1) : .clear, in: RoundedRectangle(cornerRadius: 8))
                            .onTapGesture { withAnimation { selectedPreset = preset.0 } }
                        }
                    }
                    .padding(8)
                }

                // Summary
                GroupBox("Configuration") {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text("Model:").font(.system(size: 10)); Spacer(); Text(selectedPreset == "budget" ? "Haiku" : selectedPreset == "balanced" ? "Sonnet" : "Opus").font(.system(size: 10, design: .monospaced)) }
                        HStack { Text("Cache:").font(.system(size: 10)); Spacer(); Text("Enabled").font(.system(size: 10, design: .monospaced)) }
                        HStack { Text("Streaming:").font(.system(size: 10)); Spacer(); Text("Enabled").font(.system(size: 10, design: .monospaced)) }
                    }
                    .padding(8)
                }
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Apply") {
                    store.showToast("Setup applied: \(selectedPreset)", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 400, height: 440)
    }
}
