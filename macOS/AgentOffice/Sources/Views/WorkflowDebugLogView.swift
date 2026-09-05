// WorkflowDebugLogView.swift
import SwiftUI

struct WorkflowDebugLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let logs: [(String, String, LogLevel)] = [
        ("2026-09-06 10:30:15", "App launched", .info),
        ("2026-09-06 10:30:16", "Loaded 290 agents", .info),
        ("2026-09-06 10:30:17", "API key configured", .info),
        ("2026-09-06 10:31:00", "Workflow started: parallel", .info),
        ("2026-09-06 10:31:05", "Agent Architect completed", .success),
        ("2026-09-06 10:31:08", "Agent Builder completed", .success),
        ("2026-09-06 10:31:12", "Rate limit warning", .warning),
        ("2026-09-06 10:31:15", "Workflow completed", .success),
    ]

    enum LogLevel {
        case info, success, warning, error

        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Debug Log").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(logs.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(logs[index].2.color)
                                .frame(width: 6, height: 6)
                                .offset(y: 4)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(logs[index].0)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Text(logs[index].1)
                                    .font(.system(size: 10, design: .monospaced))
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(logs.count) entries")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Copy Log") { copyLogs() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }

    private func copyLogs() {
        let text = logs.map { "[\($0.0)] \($0.1)" }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
