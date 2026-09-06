// WorkflowAgentWorkspaceLayoutView.swift
import SwiftUI

struct WorkflowAgentWorkspaceLayoutView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let layouts = ["Standard", "Wide Chat", "Focus Mode", "Dashboard", "Compact"]
    @State private var selectedLayout = "Standard"

    private let layoutDetails: [String: (String, [String])] = [
        "Standard": ("Balanced layout with sidebar, grid, and chat", ["Sidebar", "Office Grid", "Chat Panel"]),
        "Wide Chat": ("Expanded chat for long conversations", ["Sidebar", "Office Grid", "Wide Chat"]),
        "Focus Mode": ("Minimal UI for deep work", ["Office Grid", "Compact Chat"]),
        "Dashboard": ("Analytics-focused with metrics", ["Sidebar", "Metrics", "Chat"]),
        "Compact": ("Space-efficient for small screens", ["Compact Sidebar", "Grid", "Chat"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workspace Layout").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Layout selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Layout")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(layouts, id: \.self) { layout in
                            LayoutOptionCard(
                                name: layout,
                                description: layoutDetails[layout]?.0 ?? "",
                                panels: layoutDetails[layout]?.1 ?? [],
                                isSelected: selectedLayout == layout
                            ) {
                                selectedLayout = layout
                            }
                        }
                    }
                }
            }
            .padding()

            Divider()

            // Current layout preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Current: \(selectedLayout)")
                    .font(.system(size: 11, weight: .semibold))
                HStack(spacing: 4) {
                    ForEach(layoutDetails[selectedLayout]?.1 ?? [], id: \.self) { panel in
                        Text(panel)
                            .font(.system(size: 9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.blue.opacity(0.2), in: Capsule())
                            .foregroundStyle(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Divider()

            HStack {
                Button("Apply") {
                    store.showToast("Layout applied: \(selectedLayout)", type: .success)
                }
                .buttonStyle(.borderedProminent)
                Button("Reset") { selectedLayout = "Standard" }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 460, height: 380)
    }
}

// MARK: - Layout Option Card
struct LayoutOptionCard: View {
    let name: String
    let description: String
    let panels: [String]
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(name)
                        .font(.system(size: 11, weight: .semibold))
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    ForEach(panels.prefix(3), id: \.self) { panel in
                        Text(panel)
                            .font(.system(size: 7))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(.quaternary, in: Capsule())
                    }
                }
            }
            .frame(width: 140, alignment: .leading)
            .padding(10)
            .background(isSelected ? .blue.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}