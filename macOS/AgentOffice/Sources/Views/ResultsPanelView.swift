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

            // Results list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredResults) { result in
                        ResultCard(result: result)
                    }
                }
                .padding(12)
            }
        }
        .background(.background)
        .overlay(alignment: .leading) {
            Divider()
        }
    }
}

// MARK: - Result Card
struct ResultCard: View {
    let result: SessionResult
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
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }
}
