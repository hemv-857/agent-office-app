// DragDropHandler.swift
import SwiftUI
import UniformTypeIdentifiers

struct DragDropHandler: View {
    @Binding var droppedFiles: [DroppedFile]
    let onDrop: ([DroppedFile]) -> Void

    @State private var isDragOver = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(isDragOver ? Color.accentColor : Color.clear, lineWidth: 2)
            .background(isDragOver ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .overlay(
                Group {
                    if isDragOver {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.down.doc")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.accentColor)
                            Text("Drop files here")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            )
            .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
                handleDrop(providers: providers)
                return true
            }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                let file = DroppedFile(
                    name: url.lastPathComponent,
                    url: url,
                    size: Self.fileSize(url: url),
                    type: url.pathExtension
                )
                DispatchQueue.main.async {
                    self.droppedFiles.append(file)
                    self.onDrop([file])
                }
            }
        }
    }

    static func fileSize(url: URL) -> Int64 {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return 0 }
        return size
    }
}

// MARK: - Dropped File
struct DroppedFile: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let size: Int64
    let type: String

    var formattedSize: String {
        if size < 1024 { return "\(size) B" }
        if size < 1024 * 1024 { return String(format: "%.1f KB", Double(size) / 1024) }
        return String(format: "%.1f MB", Double(size) / (1024 * 1024))
    }
}

// MARK: - File Preview
struct DroppedFilePreview: View {
    let file: DroppedFile
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: fileIcon)
                .font(.system(size: 12))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 1) {
                Text(file.name)
                    .font(.system(size: 10))
                    .lineLimit(1)
                Text(file.formattedSize)
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
    }

    var fileIcon: String {
        switch file.type.lowercased() {
        case "txt", "md": return "doc.text"
        case "pdf": return "doc.richtext"
        case "png", "jpg", "jpeg", "gif": return "photo"
        case "json": return "doc.plaintext"
        case "swift": return "swift"
        case "py": return "terminal"
        default: return "doc"
        }
    }
}
