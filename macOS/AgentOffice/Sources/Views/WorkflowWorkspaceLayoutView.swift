// WorkflowWorkspaceLayoutView.swift
import SwiftUI

struct WorkflowWorkspaceLayoutView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedLayout = "standard"

    private let layouts = [
        ("standard", "Standard", "2x4 grid", "square.grid.2x2"),
        ("compact", "Compact", "3x3 grid", "square.grid.3x3"),
        ("wide", "Wide", "4x2 grid", "rectangle.righthalf.inward.filled"),
        ("focused", "Focused", "Single agent", "rectangle.center.inset.filled"),
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

            ScrollView {
                VStack(spacing: 12) {
                    // Layout options
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(layouts, id: \.0) { layout in
                            LayoutCard(
                                name: layout.1,
                                description: layout.2,
                                icon: layout.3,
                                isSelected: selectedLayout == layout.0
                            )
                            .onTapGesture { selectedLayout = layout.0 }
                        }
                    }

                    // Preview
                    GroupBox("Preview") {
                        VStack(spacing: 8) {
                            if selectedLayout == "standard" {
                                HStack(spacing: 8) {
                                    ForEach(1...4, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 50)
                                    }
                                }
                                HStack(spacing: 8) {
                                    ForEach(1...4, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 50)
                                    }
                                }
                            } else if selectedLayout == "compact" {
                                HStack(spacing: 6) {
                                    ForEach(1...3, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 40)
                                    }
                                }
                                HStack(spacing: 6) {
                                    ForEach(1...3, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 40)
                                    }
                                }
                                HStack(spacing: 6) {
                                    ForEach(1...3, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 40)
                                    }
                                }
                            } else if selectedLayout == "wide" {
                                HStack(spacing: 10) {
                                    ForEach(1...2, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 60)
                                    }
                                }
                                HStack(spacing: 10) {
                                    ForEach(1...2, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.quaternary)
                                            .frame(height: 60)
                                    }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.quaternary)
                                    .frame(height: 100)
                                    .overlay(Text("Single Agent Focus").foregroundStyle(.secondary).font(.system(size: 10)))
                            }
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Apply Layout") {
                    store.showToast("Layout changed to \(selectedLayout)", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 520)
    }
}

// MARK: - Layout Card
struct LayoutCard: View {
    let name: String
    let description: String
    let icon: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            Text(name)
                .font(.system(size: 12, weight: .semibold))
            Text(description)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
        )
    }
}
