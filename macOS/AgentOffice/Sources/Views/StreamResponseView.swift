// StreamResponseView.swift
import SwiftUI

struct StreamResponseView: View {
    @Binding var streamedText: String
    let isStreaming: Bool
    @State private var displayedText = ""
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isStreaming {
                    ProgressView()
                        .controlSize(.small)
                    Text("Streaming...")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                } else if !streamedText.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 10))
                    Text("Complete")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !streamedText.isEmpty {
                    Button(action: { copyToClipboard() }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Copy response")
                }
            }

            MarkdownText(text: displayedText, fontSize: 12)
                .textSelection(.enabled)

            if isStreaming {
                Text("▊")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.accentColor)
                    .opacity(blinkOpacity)
            }
        }
        .onChange(of: streamedText) { newValue in
            updateDisplay()
        }
        .onAppear {
            updateDisplay()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    @State private var blinkOpacity: Double = 1.0

    private func updateDisplay() {
        if isStreaming {
            // Typewriter effect
            let targetText = streamedText
            var currentIndex = displayedText.count

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                if currentIndex < targetText.count {
                    let endIndex = targetText.index(targetText.startIndex, offsetBy: currentIndex + 1)
                    displayedText = String(targetText[..<endIndex])
                    currentIndex += 1
                } else {
                    displayedText = targetText
                    timer?.invalidate()
                }
            }

            // Blink cursor
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                blinkOpacity = blinkOpacity == 1 ? 0 : 1
            }
        } else {
            displayedText = streamedText
        }
    }

    private func copyToClipboard() {
        ClipboardHistoryManager.shared.copyToClipboard(streamedText)
    }
}
