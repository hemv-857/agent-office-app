// SessionExportOptionsView.swift
import SwiftUI

struct SessionExportOptionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let formats: [(String, String, String)] = [
        ("JSON", "Raw data export", "doc.text"),
        ("Markdown", "Formatted text", "doc.richtext"),
        ("CSV", "Spreadsheet compatible", "tablecells"),
        ("PDF", "Print-ready document", "doc.plaintext"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Export Options").font(.headline)
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
                    ForEach(formats, id: \.0) { format in
                        ExportFormatRow(
                            name: format.0,
                            description: format.1,
                            icon: format.2,
                            onExport: { exportSession(format: format.0) }
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
        .frame(width: 400, height: 380)
    }

    private func exportSession(format: String) {
        switch format {
        case "JSON":
            let json = store.exportResultsAsJSON()
            NSSavePanel.saveString(json, suggestedFilename: "session.json")
        case "Markdown":
            let md = store.exportResultsAsMarkdown()
            NSSavePanel.saveString(md, suggestedFilename: "session.md")
        default:
            break
        }
        dismiss()
    }
}

// MARK: - Export Format Row
struct ExportFormatRow: View {
    let name: String
    let description: String
    let icon: String
    let onExport: () -> Void

    var body: some View {
        Button(action: onExport) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 12, weight: .medium))
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.right.circle")
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - NSSavePanel Extension
extension NSSavePanel {
    static func saveString(_ content: String, suggestedFilename: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedFilename
        panel.canCreateDirectories = true
        panel.allowsOtherFileTypes = true

        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
