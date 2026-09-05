// WorkflowChangelogDetailView.swift
import SwiftUI

struct WorkflowChangelogDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Changelog").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // v1.1.0
                    DetailChangelogSection(
                        version: "1.1.0",
                        date: "September 2026",
                        changes: [
                            ("Added", "Agent performance metrics dashboard"),
                            ("Added", "Collaboration heatmap visualization"),
                            ("Added", "Cost trend charts and forecasting"),
                            ("Added", "System health monitoring"),
                            ("Added", "Performance tips and insights"),
                            ("Improved", "Faster workflow execution"),
                            ("Fixed", "Memory usage optimization"),
                        ]
                    )

                    // v1.0.0
                    DetailChangelogSection(
                        version: "1.0.0",
                        date: "August 2026",
                        changes: [
                            ("Added", "10 workflow modes"),
                            ("Added", "15 workflow templates"),
                            ("Added", "Voice input support"),
                            ("Added", "Keyboard shortcuts"),
                            ("Added", "Session management"),
                            ("Added", "Custom agent creation"),
                            ("Added", "Data export/import"),
                        ]
                    )
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
        .frame(width: 450, height: 480)
    }
}

// MARK: - Detail Changelog Section
struct DetailChangelogSection: View {
    let version: String
    let date: String
    let changes: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("v\(version)")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text(date)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            ForEach(changes, id: \.1) { change in
                HStack(alignment: .top, spacing: 6) {
                    Text(change.0)
                        .font(.system(size: 9, weight: .medium))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(change.0 == "Added" ? Color.green.opacity(0.2) : change.0 == "Fixed" ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2), in: Capsule())
                        .foregroundStyle(change.0 == "Added" ? .green : change.0 == "Fixed" ? .orange : .blue)
                    Text(change.1)
                        .font(.system(size: 11))
                }
            }
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
