// SessionComparisonView.swift
import SwiftUI

struct SessionComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let sessions: [(String, Int, Int, Double)] = [
        ("Session 1", 8, 1250, 0.045),
        ("Session 2", 12, 2100, 0.078),
        ("Session 3", 5, 800, 0.025),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Comparison").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sessions.indices, id: \.self) { index in
                        SessionComparisonRow(
                            name: sessions[index].0,
                            agents: sessions[index].1,
                            tokens: sessions[index].2,
                            cost: sessions[index].3
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
        .frame(width: 500, height: 400)
    }
}

// MARK: - Comparison Row
struct SessionComparisonRow: View {
    let name: String
    let agents: Int
    let tokens: Int
    let cost: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name).font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(String(format: "$%.3f", cost))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(cost > 0.05 ? .red : .green)
            }

            HStack(spacing: 16) {
                MetricPill(label: "Agents", value: "\(agents)")
                MetricPill(label: "Tokens", value: "\(tokens)")
                MetricPill(label: "Cost", value: String(format: "$%.3f", cost))
            }
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Metric Pill
struct MetricPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor), in: Capsule())
    }
}
