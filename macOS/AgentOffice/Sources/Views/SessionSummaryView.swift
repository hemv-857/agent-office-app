// SessionSummaryView.swift
import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let results: [SessionResult]
    let prompt: String
    let mode: WorkflowMode

    var totalTokens: Int {
        results.reduce(0) { $0 + $1.tokensUsed }
    }

    var totalCost: Double {
        results.reduce(0) { $0 + $1.costUsd }
    }

    var averageTime: Double {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0) { $0 + $1.elapsedMs } / Double(results.count)
    }

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
                VStack(spacing: 16) {
                    // Stats
                    HStack(spacing: 16) {
                        SummaryStatCard(title: "Agents", value: "\(results.count)", icon: "person.3", color: .blue)
                        SummaryStatCard(title: "Tokens", value: formatTokens(totalTokens), icon: "text.alignleft", color: .green)
                        SummaryStatCard(title: "Cost", value: String(format: "$%.4f", totalCost), icon: "dollarsign.circle", color: .orange)
                        SummaryStatCard(title: "Avg Time", value: String(format: "%.1fs", averageTime / 1000), icon: "clock", color: .purple)
                    }

                    // Prompt
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prompt").font(.system(size: 11, weight: .semibold))
                        Text(prompt)
                            .font(.system(size: 11))
                            .padding(8)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                    }

                    // Mode
                    HStack {
                        Text("Mode").font(.system(size: 11, weight: .semibold))
                        Spacer()
                        Text(mode.rawValue.capitalized)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.blue.opacity(0.1), in: Capsule())
                            .foregroundStyle(.blue)
                    }

                    // Results summary
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Results").font(.system(size: 11, weight: .semibold))
                        ForEach(results) { result in
                            HStack {
                                Text(result.agentName)
                                    .font(.system(size: 10))
                                    .frame(width: 80, alignment: .leading)
                                ProgressView(value: Double(result.response.count), total: 500)
                                    .frame(maxWidth: .infinity)
                                Text("\(result.response.count) chars")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    exportSummary()
                }
                .buttonStyle(.bordered)

                Button("Copy") {
                    copySummary()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }

    func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 { return String(format: "%.1fM", Double(tokens) / 1_000_000) }
        if tokens >= 1_000 { return String(format: "%.1fK", Double(tokens) / 1_000) }
        return "\(tokens)"
    }

    func exportSummary() {
        if let data = PDFExportService.shared.exportResults(results) {
            PDFExportService.shared.savePDF(data, suggestedName: "session-summary.pdf")
        }
    }

    func copySummary() {
        var text = "Session Summary\n"
        text += "Prompt: \(prompt)\n"
        text += "Mode: \(mode.rawValue)\n"
        text += "Agents: \(results.count)\n"
        text += "Total Tokens: \(totalTokens)\n"
        text += "Total Cost: $\(String(format: "%.4f", totalCost))\n"
        for result in results {
            text += "\n\(result.agentName):\n\(result.response.prefix(200))\n"
        }
        ClipboardHistoryManager.shared.copyToClipboard(text)
    }
}

// MARK: - Summary Stat Card
struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
