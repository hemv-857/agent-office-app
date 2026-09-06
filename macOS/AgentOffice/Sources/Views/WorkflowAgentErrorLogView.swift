// WorkflowAgentErrorLogView.swift
import SwiftUI

struct WorkflowAgentErrorLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedSeverity = "all"

    private let errors: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-300), "Builder", "Rate limit exceeded (429)", "critical", .red),
        (Date().addingTimeInterval(-600), "Tester", "Timeout waiting for API response", "warning", .orange),
        (Date().addingTimeInterval(-900), "Reviewer", "Invalid JSON in response body", "warning", .orange),
        (Date().addingTimeInterval(-1200), "Builder", "Model hallucination detected", "critical", .red),
        (Date().addingTimeInterval(-1500), "Planner", "Budget limit reached", "warning", .orange),
        (Date().addingTimeInterval(-1800), "Security", "Authentication token expired", "critical", .red),
        (Date().addingTimeInterval(-2100), "Architect", "Rate limit warning (80%)", "info", .blue),
        (Date().addingTimeInterval(-2400), "Tester", "Incomplete response from model", "warning", .orange),
    ]

    private let errorStats: [(String, Int, Color)] = [
        ("Critical", 3, .red),
        ("Warning", 4, .orange),
        ("Info", 1, .blue),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Error Log").font(.headline)
                Spacer()
                Text("\(errors.count) errors")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Stats
            HStack(spacing: 12) {
                ForEach(errorStats, id: \.0) { stat in
                    ErrorStatBadge(label: stat.0, count: stat.1, color: stat.2)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Filter
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(["all", "critical", "warning", "info"], id: \.self) { filter in
                        Text(filter.capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedSeverity == filter ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedSeverity == filter ? .white : .primary)
                            .onTapGesture { selectedSeverity = filter }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)

            // Error list
            List {
                ForEach(errors.indices, id: \.self) { i in
                    ErrorLogRow(
                        date: errors[i].0,
                        agent: errors[i].1,
                        message: errors[i].2,
                        severity: errors[i].3,
                        severityColor: errors[i].4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Clear Log") {
                    store.showToast("Error log cleared", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Error Stat Badge
struct ErrorStatBadge: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Error Log Row
struct ErrorLogRow: View {
    let date: Date
    let agent: String
    let message: String
    let severity: String
    let severityColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(severityColor)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(agent)
                        .font(.system(size: 11, weight: .semibold))
                    Text(severity.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(severityColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(severityColor)
                }
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(date, style: .relative)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
