// WorkflowSystemStatusView.swift
import SwiftUI

struct WorkflowSystemStatusView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let services: [(String, String, Bool)] = [
        ("Anthropic API", "Claude model access", true),
        ("OpenAI API", "GPT model access", false),
        ("Ollama", "Local model server", true),
        ("Network", "Internet connectivity", true),
        ("Storage", "Local cache", true),
        ("Voice", "Speech recognition", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Status").font(.headline)
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
                    // Overall status
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 10, height: 10)
                        Text("All systems operational")
                            .font(.system(size: 12, weight: .semibold))
                        Spacer()
                    }
                    .padding()
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                    // Services
                    ForEach(services, id: \.0) { service in
                        ServiceStatusRow(
                            name: service.0,
                            description: service.1,
                            available: service.2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                let available = services.filter { $0.2 }.count
                Text("\(available)/\(services.count) services online")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 420)
    }
}

// MARK: - Service Status Row
struct ServiceStatusRow: View {
    let name: String
    let description: String
    let available: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(available ? .green : .red)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(available ? "Online" : "Offline")
                .font(.system(size: 9))
                .foregroundStyle(available ? .green : .red)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}
