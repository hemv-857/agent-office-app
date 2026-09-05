// WorkflowSystemLogsView.swift
import SwiftUI

struct WorkflowSystemLogsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var logLevel = "All"

    private let levels = ["All", "Info", "Warning", "Error"]

    private let logs: [(Date, String, String)] = [
        (Date().addingTimeInterval(-60), "INFO", "App launched successfully"),
        (Date().addingTimeInterval(-120), "INFO", "Loaded 290 agents"),
        (Date().addingTimeInterval(-180), "WARNING", "Rate limit approaching"),
        (Date().addingTimeInterval(-240), "INFO", "Workflow completed"),
        (Date().addingTimeInterval(-300), "ERROR", "API connection timeout"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Logs").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Level picker
            Picker("Level", selection: $logLevel) {
                ForEach(levels, id: \.self) { level in
                    Text(level).tag(level)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(logs.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Text(formatTime(logs[index].0))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .leading)
                            Text(logs[index].1)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundStyle(colorForLevel(logs[index].1))
                                .frame(width: 50, alignment: .leading)
                            Text(logs[index].2)
                                .font(.system(size: 10, design: .monospaced))
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
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func colorForLevel(_ level: String) -> Color {
        switch level {
        case "ERROR": return .red
        case "WARNING": return .orange
        default: return .blue
        }
    }
}
