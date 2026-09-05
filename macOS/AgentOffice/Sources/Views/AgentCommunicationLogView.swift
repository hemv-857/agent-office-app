// AgentCommunicationLogView.swift
import SwiftUI

struct AgentCommunicationLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var logs: [CommunicationLog] = []
    @State private var filter: LogFilter = .all

    enum LogFilter: String, CaseIterable {
        case all = "All"
        case requests = "Requests"
        case responses = "Responses"
        case errors = "Errors"
    }

    struct CommunicationLog: Identifiable {
        let id = UUID()
        let agentName: String
        let agentEmoji: String
        let type: LogType
        let message: String
        let timestamp: Date
        let tokens: Int?
        let duration: TimeInterval?

        enum LogType {
            case request, response, error

            var icon: String {
                switch self {
                case .request: return "arrow.up.circle"
                case .response: return "arrow.down.circle"
                case .error: return "exclamationmark.circle"
                }
            }

            var color: Color {
                switch self {
                case .request: return .blue
                case .response: return .green
                case .error: return .red
                }
            }
        }
    }

    var filteredLogs: [CommunicationLog] {
        switch filter {
        case .all: return logs
        case .requests: return logs.filter { $0.type == .request }
        case .responses: return logs.filter { $0.type == .response }
        case .errors: return logs.filter { $0.type == .error }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Communication Log").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filter
            Picker("", selection: $filter) {
                ForEach(LogFilter.allCases, id: \.self) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Logs
            if filteredLogs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "network").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No communication logs").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredLogs) { log in
                            LogRow(log: log)
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Text("\(filteredLogs.count) entries")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Clear") { logs.removeAll() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 550, height: 480)
    }
}

// MARK: - Log Row
struct LogRow: View {
    let log: AgentCommunicationLogView.CommunicationLog

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(log.agentEmoji)
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(log.agentName)
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: log.type.icon)
                        .font(.system(size: 9))
                        .foregroundStyle(log.type.color)
                    Spacer()
                    Text(log.timestamp, style: .time)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }

                Text(log.message)
                    .font(.system(size: 10))
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    if let tokens = log.tokens {
                        Text("\(tokens) tokens")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    if let duration = log.duration {
                        Text(String(format: "%.2fs", duration))
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
