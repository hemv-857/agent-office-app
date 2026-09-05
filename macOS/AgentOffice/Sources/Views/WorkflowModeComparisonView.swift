// WorkflowModeComparisonView.swift
import SwiftUI

struct WorkflowModeComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let modes: [(String, String, String, String)] = [
        ("Parallel", "Speed", "All agents run at once", "Best for independent tasks"),
        ("Pipeline", "Quality", "Sequential chain", "Best for dependent tasks"),
        ("Synthesis", "Depth", "Merge all outputs", "Best for comprehensive analysis"),
        ("Review", "Accuracy", "Peer review", "Best for code quality"),
        ("Debate", "Decisions", "Structured discussion", "Best for tradeoffs"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Mode Comparison").font(.headline)
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
                    ForEach(modes, id: \.0) { mode in
                        ModeComparisonRow(
                            name: mode.0,
                            strength: mode.1,
                            description: mode.2,
                            bestFor: mode.3
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
        .frame(width: 500, height: 450)
    }
}

// MARK: - Mode Comparison Row
struct ModeComparisonRow: View {
    let name: String
    let strength: String
    let description: String
    let bestFor: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(strength)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
                Text(bestFor)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
