// WorkflowModelPerformanceView.swift
import SwiftUI

struct WorkflowModelPerformanceView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let models: [(String, String, String, String, String, Double)] = [
        ("Claude 3.5 Sonnet", "Anthropic", "128K", "3.0/15.0", "95%", 0.95),
        ("Claude 3 Haiku", "Anthropic", "200K", "0.25/1.25", "88%", 0.88),
        ("Claude 3 Opus", "Anthropic", "200K", "15/75", "98%", 0.98),
        ("GPT-4o", "OpenAI", "128K", "2.5/10.0", "93%", 0.93),
        ("GPT-4o Mini", "OpenAI", "128K", "0.15/0.6", "85%", 0.85),
        ("Ollama Llama 3.1", "Local", "128K", "Free", "75%", 0.75),
        ("Ollama Mistral", "Local", "32K", "Free", "72%", 0.72),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Model Performance").font(.headline)
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
                    // Header
                    HStack(spacing: 12) {
                        ModelPerfStat(title: "Models", value: "\(models.count)", icon: "cpu", color: .blue)
                        ModelPerfStat(title: "Current", value: store.selectedModel, icon: "checkmark.circle", color: .green)
                        ModelPerfStat(title: "Provider", value: store.selectedProvider.displayName, icon: "cloud", color: .purple)
                    }

                    // Model comparison table
                    GroupBox("Model Comparison") {
                        VStack(spacing: 1) {
                            // Header
                            HStack(spacing: 12) {
                                Text("Model")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 120, alignment: .leading)
                                Text("Context")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 50)
                                Text("Cost/M")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 60)
                                Text("Quality")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 50)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(.quaternary)

                            ForEach(models, id: \.0) { model in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading) {
                                        Text(model.0)
                                            .font(.system(size: 10, weight: .medium))
                                        Text(model.1)
                                            .font(.system(size: 8))
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(width: 120, alignment: .leading)
                                    Text(model.2)
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50)
                                    Text(model.3)
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 60)
                                    ProgressView(value: model.5)
                                        .frame(width: 50)
                                        .tint(model.5 >= 0.9 ? .green : model.5 >= 0.8 ? .blue : .orange)
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)

                                if model.0 != models.last?.0 {
                                    Divider().padding(.horizontal, 8)
                                }
                            }
                        }
                        .padding(4)
                    }

                    // Recommendations
                    GroupBox("Recommendations") {
                        VStack(alignment: .leading, spacing: 8) {
                            ModelRecommendation(
                                model: "Claude 3.5 Sonnet",
                                reason: "Best for complex coding tasks",
                                icon: "star.fill",
                                color: .yellow
                            )
                            ModelRecommendation(
                                model: "Claude 3 Haiku",
                                reason: "Best for simple, high-volume tasks",
                                icon: "bolt.fill",
                                color: .blue
                            )
                            ModelRecommendation(
                                model: "Ollama Local",
                                reason: "Best for offline/privacy-sensitive work",
                                icon: "desktopcomputer",
                                color: .green
                            )
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
        .frame(width: 540, height: 560)
    }
}

// MARK: - Model Perf Stat
struct ModelPerfStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .lineLimit(1)
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Model Recommendation
struct ModelRecommendation: View {
    let model: String
    let reason: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            VStack(alignment: .leading) {
                Text(model).font(.system(size: 11, weight: .medium))
                Text(reason).font(.system(size: 10)).foregroundStyle(.secondary)
            }
        }
    }
}
