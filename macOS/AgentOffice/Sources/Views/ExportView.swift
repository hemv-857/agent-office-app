// ExportView.swift
import SwiftUI

struct ExportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var exportedText = ""
    @State private var format = "markdown"
    @State private var exportMode = "all" // all, selected, bookmarked

    var resultsToExport: [SessionResult] {
        switch exportMode {
        case "selected":
            return store.results.filter { store.selectedResults.contains($0.id) }
        case "bookmarked":
            return store.results.filter { $0.isBookmarked }
        default:
            return store.results
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Export Results").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Format picker
            HStack(spacing: 12) {
                Picker("Format", selection: $format) {
                    Text("Markdown").tag("markdown")
                    Text("JSON").tag("json")
                }
                .pickerStyle(.segmented)
                .frame(width: 200)

                Picker("Export", selection: $exportMode) {
                    Text("All (\(store.results.count))").tag("all")
                    Text("Selected (\(store.selectedResults.count))").tag("selected")
                    Text("Bookmarked (\(store.results.filter { $0.isBookmarked }.count))").tag("bookmarked")
                }
                .pickerStyle(.menu)
                .frame(width: 160)
            }
            .padding()

            // Preview
            ScrollView {
                Text(exportedText)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)

            Divider()

            HStack {
                Button(action: {
                    exportedText = format == "markdown" ? exportAsMarkdown() : exportAsJSON()
                }) {
                    Label("Generate", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(exportedText, forType: .string)
                    store.showToast("Copied to clipboard", type: .success)
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .disabled(exportedText.isEmpty)

                Button(action: {
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.plainText, .json]
                    panel.nameFieldStringValue = "agent-results.\(format == "markdown" ? "md" : "json")"
                    panel.begin { result in
                        if result == .OK, let url = panel.url {
                            try? exportedText.write(to: url, atomically: true, encoding: .utf8)
                            store.showToast("Saved", type: .success)
                        }
                    }
                }) {
                    Label("Save File", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .disabled(exportedText.isEmpty)
            }
            .padding()
        }
        .frame(width: 600, height: 520)
        .onAppear { exportedText = exportAsMarkdown() }
        .onChange(of: format) { _ in generateExport() }
        .onChange(of: exportMode) { _ in generateExport() }
    }

    func generateExport() {
        exportedText = format == "markdown" ? exportAsMarkdown() : exportAsJSON()
    }

    func exportAsMarkdown() -> String {
        resultsToExport.map { r in
            "# \(r.agentName)\n\nStatus: \(r.status.rawValue)\nTokens: \(r.tokensUsed)\nCost: $\(String(format: "%.4f", r.costUsd))\nTime: \(r.elapsedMs > 0 ? String(format: "%.1fs", r.elapsedMs / 1000) : "N/A")\n\n---\n\n\(r.response)"
        }.joined(separator: "\n\n")
    }

    func exportAsJSON() -> String {
        let data = resultsToExport.map { ["agent": $0.agentName, "response": $0.response, "status": $0.status.rawValue, "cost": $0.costUsd, "tokens": $0.tokensUsed] as [String: Any] }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
              let json = String(data: jsonData, encoding: .utf8) else { return "[]" }
        return json
    }
}
