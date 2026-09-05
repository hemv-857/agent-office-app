// WorkflowTroubleshootingView.swift
import SwiftUI

struct WorkflowTroubleshootingView: View {
    @Environment(\.dismiss) var dismiss

    private let issues: [(String, String, String)] = [
        ("No API Key", "Set your API key in Settings", "key.fill"),
        ("Rate Limited", "Wait a moment and try again", "clock.fill"),
        ("No Agents", "Select agents from the sidebar", "person.3.fill"),
        ("Empty Prompt", "Enter a prompt to run", "text.cursor"),
        ("Network Error", "Check your internet connection", "wifi.slash"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Troubleshooting").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(issues, id: \.0) { issue in
                        TroubleshootingRow(
                            title: issue.0,
                            solution: issue.1,
                            icon: issue.2
                        )
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
        .frame(width: 420, height: 400)
    }
}

// MARK: - Troubleshooting Row
struct TroubleshootingRow: View {
    let title: String
    let solution: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.orange)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(solution)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}
