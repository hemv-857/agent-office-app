// ClipboardHistoryView.swift
import SwiftUI

struct ClipboardHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @StateObject private var clipboardManager = ClipboardHistoryManager.shared
    @State private var searchText = ""

    private var filteredEntries: [ClipboardHistoryManager.ClipboardEntry] {
        if searchText.isEmpty { return clipboardManager.history }
        return clipboardManager.history.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Clipboard History").font(.headline)
                Spacer()
                if clipboardManager.isMonitoring {
                    Image(systemName: "circle.fill").foregroundStyle(.green).font(.system(size: 8))
                    Text("Monitoring").font(.caption).foregroundStyle(.secondary)
                }
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Entries
            if filteredEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.on.clipboard").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No clipboard entries").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredEntries) { entry in
                        ClipboardEntryRow(entry: entry) {
                            clipboardManager.copyToClipboard(entry.content)
                            store.showToast("Copied to clipboard", type: .success)
                        } onDelete: {
                            clipboardManager.removeEntry(entry)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Text("\(filteredEntries.count) entries")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Toggle Monitoring") {
                    if clipboardManager.isMonitoring {
                        clipboardManager.stopMonitoring()
                    } else {
                        clipboardManager.startMonitoring()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Clear All") { clipboardManager.clearHistory() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .onAppear {
            if !clipboardManager.isMonitoring {
                clipboardManager.startMonitoring()
            }
        }
    }
}

// MARK: - Entry Row
struct ClipboardEntryRow: View {
    let entry: ClipboardHistoryManager.ClipboardEntry
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.content)
                    .font(.system(size: 11))
                    .lineLimit(3)
                    .textSelection(.enabled)
                HStack {
                    Text(entry.source)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text(entry.timestamp, style: .relative)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(.vertical, 4)
    }
}
