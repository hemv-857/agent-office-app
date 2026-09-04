// ResultsPanelView.swift
import SwiftUI

struct ResultsPanelView: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""

    var filteredResults: [SessionResult] {
        if searchText.isEmpty { return store.results }
        return store.results.filter {
            $0.agentName.localizedCaseInsensitiveContains(searchText) ||
            $0.response.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Text("Results")
                    .font(.system(size: 13, weight: .semibold))
                Text("\(store.results.count)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.quaternary, in: Capsule())

                Spacer()

                // Compare mode toggle
                if store.results.count >= 2 {
                    Button(action: { store.compareMode.toggle() }) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 10))
                            Text("Compare")
                                .font(.system(size: 10))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(store.compareMode ? Color.accentColor.opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(store.compareMode ? .blue : .secondary)
                }

                // Session replay
                Button(action: { store.showSessionReplay = true }) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Replay session")

                if !store.results.isEmpty {
                    Button(action: {
                        let text = store.results.map { "**\($0.agentName)**\n\($0.response)" }.joined(separator: "\n\n---\n\n")
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(text, forType: .string)
                        store.showToast("Copied all results", type: .success)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .help("Copy all results")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                TextField("Filter results...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            Divider()

            // Results
            if store.compareMode && store.results.count >= 2 {
                CompareView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredResults) { result in
                            ResultCard(result: result)
                        }
                    }
                    .padding(12)
                }
            }
        }
        .background(.background)
        .overlay(alignment: .leading) {
            Divider()
        }
    }
}

// MARK: - Compare View
struct CompareView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedLeft = 0
    @State private var selectedRight = 1

    var body: some View {
        VStack(spacing: 0) {
            // Selectors
            HStack(spacing: 12) {
                Picker("Left", selection: $selectedLeft) {
                    ForEach(0..<store.results.count, id: \.self) { i in
                        Text(store.results[i].agentName).tag(i)
                    }
                }
                .labelsHidden()

                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(.secondary)

                Picker("Right", selection: $selectedRight) {
                    ForEach(0..<store.results.count, id: \.self) { i in
                        Text(store.results[i].agentName).tag(i)
                    }
                }
                .labelsHidden()
            }
            .padding(8)

            Divider()

            // Side by side
            HSplitView {
                if selectedLeft < store.results.count {
                    ResultCard(result: store.results[selectedLeft])
                }
                if selectedRight < store.results.count {
                    ResultCard(result: store.results[selectedRight])
                }
            }
        }
    }
}

// MARK: - Result Card
struct ResultCard: View {
    let result: SessionResult
    @EnvironmentObject var store: AppStore
    @State private var isExpanded = false

    var statusColor: Color {
        switch result.status {
        case .done: return .green
        case .error: return .red
        case .working: return .blue
        default: return .secondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Text(result.agentName)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()

                // Rating buttons
                if result.status == .done {
                    Button(action: { toggleRating(.up) }) {
                        Image(systemName: result.rating == .up ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 10))
                            .foregroundStyle(result.rating == .up ? .green : .secondary)
                    }
                    .buttonStyle(.plain)

                    Button(action: { toggleRating(.down) }) {
                        Image(systemName: result.rating == .down ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .font(.system(size: 10))
                            .foregroundStyle(result.rating == .down ? .red : .secondary)
                    }
                    .buttonStyle(.plain)

                    // Bookmark
                    Button(action: { toggleBookmark() }) {
                        Image(systemName: result.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 10))
                            .foregroundStyle(result.isBookmarked ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                }

                if result.elapsedMs > 0 {
                    Text(String(format: "%.1fs", result.elapsedMs / 1000))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                if result.costUsd > 0 {
                    Text(String(format: "$%.4f", result.costUsd))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
            }

            // Tokens
            if result.tokensUsed > 0 {
                Text("\(result.tokensUsed) tokens")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }

            // Response
            if result.response.isEmpty && result.status == .working {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.mini)
                    Text("Working...")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(result.response)
                    .font(.system(size: 11))
                    .foregroundStyle(result.status == .error ? .red : .primary)
                    .lineLimit(isExpanded ? nil : 4)
                    .onTapGesture { withAnimation { isExpanded.toggle() } }
            }

            // Copy button
            if !result.response.isEmpty {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(result.response, forType: .string)
                    store.showToast("Copied \(result.agentName)'s response", type: .success)
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.system(size: 9))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }

    func toggleRating(_ type: RatingType) {
        guard let idx = store.results.firstIndex(where: { $0.id == result.id }) else { return }
        if store.results[idx].rating == type {
            store.results[idx].rating = nil
        } else {
            store.results[idx].rating = type
        }
    }

    func toggleBookmark() {
        guard let idx = store.results.firstIndex(where: { $0.id == result.id }) else { return }
        store.results[idx].isBookmarked.toggle()
    }
}
