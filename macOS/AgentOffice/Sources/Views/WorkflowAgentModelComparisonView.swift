// WorkflowAgentModelComparisonView.swift
import SwiftUI

struct WorkflowAgentModelComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let models: [(String, String, String, String, String)] = [
        ("Claude 3.5 Sonnet", "Best balance", "$3/$15", "Fast", "Recommended"),
        ("Claude 3 Haiku", "Budget friendly", "$0.25/$1.25", "Fastest", "Simple tasks"),
        ("Claude 3 Opus", "Highest quality", "$15/$75", "Slow", "Complex analysis"),
        ("GPT-4o", "OpenAI flagship", "$2.50/$10", "Fast", "Alternative"),
        ("GPT-4o Mini", "OpenAI budget", "$0.15/$0.60", "Fastest", "Simple tasks"),
        ("Ollama Local", "Free & private", "Free", "Varies", "No API key"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Model Comparison").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(models.indices, id: \.self) { i in
                        ModelComparisonRow(
                            name: models[i].0,
                            description: models[i].1,
                            cost: models[i].2,
                            speed: models[i].3,
                            useCase: models[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 440)
    }
}

// MARK: - Model Comparison Row
struct ModelComparisonRow: View {
    let name: String
    let description: String
    let cost: String
    let speed: String
    let useCase: String

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120, alignment: .leading)
            Text(cost)
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 60)
            Text(speed)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(speed == "Fastest" ? .green.opacity(0.15) : speed == "Slow" ? .orange.opacity(0.15) : .blue.opacity(0.15), in: Capsule())
                .foregroundStyle(speed == "Fastest" ? .green : speed == "Slow" ? .orange : .blue)
                .frame(width: 55)
            Text(useCase)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
