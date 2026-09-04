// ExportView.swift
import SwiftUI

struct ExportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var exportedText = ""
    @State private var format = "markdown"

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

            Picker("Format", selection: $format) {
                Text("Markdown").tag("markdown")
                Text("JSON").tag("json")
            }
            .pickerStyle(.segmented)
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
                    exportedText = format == "markdown" ? store.exportResultsAsMarkdown() : store.exportResultsAsJSON()
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
        .frame(width: 550, height: 500)
        .onAppear { exportedText = store.exportResultsAsMarkdown() }
        .onChange(of: format) { _ in
            exportedText = format == "markdown" ? store.exportResultsAsMarkdown() : store.exportResultsAsJSON()
        }
    }
}
