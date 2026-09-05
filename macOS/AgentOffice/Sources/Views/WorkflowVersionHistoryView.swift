// WorkflowVersionHistoryView.swift
import SwiftUI

struct WorkflowVersionHistoryView: View {
    @Environment(\.dismiss) var dismiss

    private let versions: [(String, String, [String])] = [
        ("1.1.0", "Performance Dashboard", [
            "Agent performance metrics",
            "Collaboration heatmap",
            "Cost trend charts",
            "System health monitoring",
        ]),
        ("1.0.0", "Initial Release", [
            "10 workflow modes",
            "15 workflow templates",
            "Voice input support",
            "Keyboard shortcuts",
            "Session management",
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Version History").font(.headline)
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
                    ForEach(versions, id: \.0) { version in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("v\(version.0)")
                                    .font(.system(size: 14, weight: .bold))
                                Text(version.1)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(version.2, id: \.self) { feature in
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.system(size: 8))
                                    Text(feature)
                                        .font(.system(size: 11))
                                }
                            }
                        }
                        .padding()
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 420, height: 420)
    }
}
