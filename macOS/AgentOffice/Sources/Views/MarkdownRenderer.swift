// MarkdownRenderer.swift
import SwiftUI

struct MarkdownText: View {
    let text: String
    var fontSize: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(parseBlocks(), id: \.id) { block in
                switch block.type {
                case .heading(let level):
                    headingBlock(block.content, level: level)
                case .code(let language):
                    codeBlock(block.content, language: language)
                case .bullet:
                    bulletBlock(block.content)
                case .numbered(let number):
                    numberedBlock(block.content, number: number)
                case .quote:
                    quoteBlock(block.content)
                case .bold:
                    boldBlock(block.content)
                case .plain:
                    plainBlock(block.content)
                }
            }
        }
    }

    @ViewBuilder
    func headingBlock(_ content: String, level: Int) -> some View {
        let sizes: [CGFloat] = [0, 18, 16, 14, 13, 12, 11]
        Text(content)
            .font(.system(size: sizes[min(level, 6)], weight: .bold))
            .padding(.top, 4)
    }

    @ViewBuilder
    func codeBlock(_ content: String, language: String?) -> some View {
        HStack(alignment: .top) {
            if let lang = language {
                Text(lang)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            ScrollView(.horizontal) {
                Text(content)
                    .font(.system(size: fontSize - 1, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .padding(6)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 4))
    }

    @ViewBuilder
    func bulletBlock(_ content: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").foregroundStyle(.secondary)
            Text(attributedString(content))
                .font(.system(size: fontSize))
        }
    }

    @ViewBuilder
    func numberedBlock(_ content: String, number: Int) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(number).").foregroundStyle(.secondary)
            Text(attributedString(content))
                .font(.system(size: fontSize))
        }
    }

    @ViewBuilder
    func quoteBlock(_ content: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accentColor)
                .frame(width: 3)
            Text(content)
                .font(.system(size: fontSize))
                .foregroundStyle(.secondary)
                .italic()
        }
        .padding(.leading, 4)
    }

    @ViewBuilder
    func boldBlock(_ content: String) -> some View {
        Text(content)
            .font(.system(size: fontSize, weight: .bold))
    }

    @ViewBuilder
    func plainBlock(_ content: String) -> some View {
        Text(attributedString(content))
            .font(.system(size: fontSize))
    }

    func attributedString(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        // Bold
        while let boldRange = result.range(of: "**") {
            guard let endRange = result[boldRange.upperBound...].range(of: "**") else { break }
            let contentRange = boldRange.upperBound..<endRange.lowerBound
            result[contentRange].font = .system(size: fontSize, weight: .bold)
            result.removeSubrange(endRange)
            result.removeSubrange(boldRange)
        }
        // Inline code
        while let startRange = result.range(of: "`") {
            guard let endRange = result[startRange.upperBound...].range(of: "`") else { break }
            let contentRange = startRange.upperBound..<endRange.lowerBound
            result[contentRange].font = .system(size: fontSize, design: .monospaced)
            result[contentRange].backgroundColor = Color(nsColor: .controlBackgroundColor)
            result.removeSubrange(endRange)
            result.removeSubrange(startRange)
        }
        return result
    }

    func parseBlocks() -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = text.components(separatedBy: "\n")
        var numberedCounter = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                numberedCounter = 0
                continue
            }

            if trimmed.hasPrefix("# ") {
                blocks.append(.init(type: .heading(1), content: String(trimmed.dropFirst(2))))
            } else if trimmed.hasPrefix("## ") {
                blocks.append(.init(type: .heading(2), content: String(trimmed.dropFirst(3))))
            } else if trimmed.hasPrefix("### ") {
                blocks.append(.init(type: .heading(3), content: String(trimmed.dropFirst(4))))
            } else if trimmed.hasPrefix("```") {
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                blocks.append(.init(type: .code(lang.isEmpty ? nil : lang), content: ""))
            } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                blocks.append(.init(type: .bullet, content: String(trimmed.dropFirst(2))))
            } else if trimmed.hasPrefix("> ") {
                blocks.append(.init(type: .quote, content: String(trimmed.dropFirst(2))))
            } else if trimmed.hasPrefix("1. ") || trimmed.hasPrefix("2. ") {
                numberedCounter += 1
                let content = trimmed.replacingOccurrences(of: "^\\d+\\.\\s", with: "", options: .regularExpression)
                blocks.append(.init(type: .numbered(numberedCounter), content: content))
            } else {
                blocks.append(.init(type: .plain, content: trimmed))
            }
        }
        return blocks
    }
}

// MARK: - Models
struct MarkdownBlock: Identifiable {
    let id = UUID()
    let type: BlockType
    let content: String

    enum BlockType {
        case heading(Int)
        case code(String?)
        case bullet
        case numbered(Int)
        case quote
        case bold
        case plain
    }
}
