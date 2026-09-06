// WorkflowAgentSessionSummaryView.swift
import SwiftUI

struct WorkflowAgentSessionSummaryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let summary: [(String, String, Color)] = [
        ("Duration", "2h 15m", .blue),
        ("Tasks Completed", "12", .green),
        ("API Calls", "47", .orange),
        ("Total Cost", "$0.84", .red),
        ("Success Rate", "94.2%", .green),
        ("Agents Used", "4", .blue),
        ("Workflows Run", "3", .purple),
        ("Errors Encountered", "2", .orange),
    ]

    private let highlights: [String] = [
        "Architect completed 3 design reviews",
        "Builder implemented 5 API endpoints",
        "Reviewer approved 4 pull requests",
        "Tester found 2 regressions (both fixed)",
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Summary").font(.headline)
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
                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(summary.indices, id: \.self) { i in
                            SessionSummaryStatCard(
                                label: summary[i].0,
                                value: summary[i].1,
                                color: summary[i].2
                            )
                        }
                    }

                    // Highlights
                    GroupBox("Session Highlights") {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(highlights.indices, id: \.self) { i in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.green)
                                    Text(highlights[i])
                                        .font(.system(size: 10))
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Rating
                    GroupBox("Session Rating") {
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= 4 ? "star.fill" : "star")
                                    .font(.system(size: 20))
                                    .foregroundStyle(i <= 4 ? .yellow : .secondary)
                            }
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export Summary") {
                    store.showToast("Summary exported", type: .success)
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

// MARK: - Session Summary Stat Card
struct SessionSummaryStatCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
