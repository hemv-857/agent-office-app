// SessionReplayView.swift
import SwiftUI

struct SessionReplayView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedResult: SessionResult?
    @State private var replayIndex = 0
    @State private var isPlaying = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Replay").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if store.results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "play.circle").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No results to replay").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Timeline
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(store.results.enumerated()), id: \.element.id) { idx, result in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(idx <= replayIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                                    .frame(width: 12, height: 12)
                                Text(result.agentName)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 60)
                            }
                            .onTapGesture {
                                replayIndex = idx
                                selectedResult = result
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                // Content
                if let result = selectedResult ?? (replayIndex < store.results.count ? store.results[replayIndex] : nil) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(result.agentName).font(.headline)
                            Spacer()
                            Text(result.status.rawValue).font(.caption).foregroundStyle(.secondary)
                            Text(String(format: "%.1fs", result.elapsedMs / 1000)).font(.caption).foregroundStyle(.secondary)
                        }
                        ScrollView {
                            Text(result.response).font(.system(size: 12, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }

                Divider()

                // Controls
                HStack {
                    Button(action: stepBack) {
                        Image(systemName: "backward.fill")
                    }
                    .buttonStyle(.plain)
                    .disabled(replayIndex == 0)

                    Button(action: togglePlay) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)

                    Button(action: stepForward) {
                        Image(systemName: "forward.fill")
                    }
                    .buttonStyle(.plain)
                    .disabled(replayIndex >= store.results.count - 1)

                    Spacer()

                    Text("\(replayIndex + 1) / \(store.results.count)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .frame(width: 550, height: 500)
        .onAppear {
            if !store.results.isEmpty {
                selectedResult = store.results[0]
            }
        }
        .onDisappear { stopTimer() }
    }

    func togglePlay() {
        if isPlaying {
            stopTimer()
        } else {
            isPlaying = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                stepForward()
            }
        }
    }

    func stopTimer() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    func stepForward() {
        guard replayIndex < store.results.count - 1 else { stopTimer(); return }
        replayIndex += 1
        selectedResult = store.results[replayIndex]
    }

    func stepBack() {
        guard replayIndex > 0 else { return }
        replayIndex -= 1
        selectedResult = store.results[replayIndex]
    }
}
