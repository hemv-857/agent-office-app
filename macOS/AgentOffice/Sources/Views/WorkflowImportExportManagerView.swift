// WorkflowImportExportManagerView.swift
import SwiftUI

struct WorkflowImportExportManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedFormat = "JSON"

    private let formats = ["JSON", "CSV", "YAML"]
    private let recentExports: [(String, String)] = [
        ("All Workflows", "2.4 KB"),
        ("Cost History", "1.8 KB"),
        ("Agent Config", "3.2 KB"),
        ("Session Data", "5.1 KB"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Import / Export Manager").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            HStack(spacing: 20) {
                // Export section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export").font(.system(size: 13, weight: .semibold))
                    Text("Format:")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Picker("", selection: $selectedFormat) {
                        ForEach(formats, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()

                    Button(action: { store.showToast("Exported as \(selectedFormat)", type: .success) }) {
                        Label("Export All", systemImage: "arrow.up.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: { store.showToast("Exported to clipboard", type: .success) }) {
                        Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Import section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import").font(.system(size: 13, weight: .semibold))
                    Text("Paste or drop file:")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 60)
                        .overlay(
                            Text("Drop file here")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        )
                    Button(action: { store.showToast("Imported successfully", type: .success) }) {
                        Label("Import", systemImage: "arrow.down.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()

            Divider()

            // Recent exports
            GroupBox("Recent Exports") {
                VStack(spacing: 4) {
                    ForEach(recentExports.indices, id: \.self) { i in
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundStyle(.secondary)
                            Text(recentExports[i].0)
                                .font(.system(size: 11, weight: .medium))
                            Spacer()
                            Text(recentExports[i].1)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}
