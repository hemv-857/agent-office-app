// WorkflowReleaseNotesView.swift
import SwiftUI

struct WorkflowReleaseNotesView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Release Notes").font(.headline)
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
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("v1.1.0")
                                .font(.system(size: 14, weight: .bold))
                            Text("Latest")
                                .font(.system(size: 9))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.green.opacity(0.2), in: Capsule())
                                .foregroundStyle(.green)
                        }
                        Text("Performance Dashboard & Analytics")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        FeatureList(features: [
                            "Agent performance metrics",
                            "Collaboration heatmap",
                            "Cost trend charts",
                            "System health monitoring",
                        ])
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // v1.0.0
                    VStack(alignment: .leading, spacing: 8) {
                        Text("v1.0.0")
                            .font(.system(size: 14, weight: .bold))
                        Text("Initial Release")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        FeatureList(features: [
                            "10 workflow modes",
                            "15 workflow templates",
                            "Voice input support",
                            "Keyboard shortcuts",
                            "Session management",
                        ])
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 450, height: 450)
    }
}

// MARK: - Feature List
struct FeatureList: View {
    let features: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                        .font(.system(size: 8))
                    Text(feature)
                        .font(.system(size: 10))
                }
            }
        }
    }
}
