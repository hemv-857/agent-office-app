// WorkflowQuickStartView.swift
import SwiftUI

struct WorkflowQuickStartView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let quickActions: [(String, String, String, WorkflowMode)] = [
        ("Quick Review", "Review code changes", "magnifyingglass", .review),
        ("Brainstorm", "Generate ideas", "brain.head.profile", .parallel),
        ("Debug Issue", "Find and fix bugs", "ant.fill", .synthesis),
        ("Write Docs", "Create documentation", "doc.text", .pipeline),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Start").font(.headline)
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
                    ForEach(quickActions, id: \.0) { action in
                        QuickStartRow(
                            title: action.0,
                            description: action.1,
                            icon: action.2,
                            onTap: {
                                store.workflowMode = action.3
                                dismiss()
                            }
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
}

// MARK: - Quick Start Row
struct QuickStartRow: View {
    let title: String
    let description: String
    let icon: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
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
