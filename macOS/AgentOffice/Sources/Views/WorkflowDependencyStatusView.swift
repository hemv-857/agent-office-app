// WorkflowDependencyStatusView.swift
import SwiftUI

struct WorkflowDependencyStatusView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let dependencies: [(String, String, Bool)] = [
        ("Anthropic API", "Claude model access", true),
        ("OpenAI API", "GPT model access", false),
        ("Ollama", "Local model server", true),
        ("Network", "Internet connectivity", true),
        ("Storage", "Local cache available", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Dependency Status").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(dependencies, id: \.0) { dep in
                        DependencyRow(
                            name: dep.0,
                            description: dep.1,
                            available: dep.2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                let available = dependencies.filter { $0.2 }.count
                Text("Available: \(available)/\(dependencies.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 380)
    }
}

// MARK: - Dependency Row
struct DependencyRow: View {
    let name: String
    let description: String
    let available: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(available ? .green : .red)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(available ? "Ready" : "Unavailable")
                .font(.system(size: 9))
                .foregroundStyle(available ? .green : .red)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}
