// HelpView.swift
import SwiftUI

struct HelpView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = "shortcuts"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Help").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("Shortcuts").tag("shortcuts")
                Text("About").tag("about")
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == "shortcuts" {
                KeyboardShortcutsHelpView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                aboutView
            }
        }
        .frame(width: 420, height: 480)
    }

    var aboutView: some View {
        VStack(spacing: 16) {
            Spacer()

            // App icon
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                )

            Text("Agent Office")
                .font(.title2.weight(.semibold))

            Text("Your AI agent command center")
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Version", value: "1.0.0")
                InfoRow(label: "Agents", value: "\(store.allAgents.count) loaded")
                InfoRow(label: "Provider", value: store.selectedProvider.displayName)
                InfoRow(label: "Desks", value: "\(store.seatedCount)/\(store.totalDesks) seated")
            }
            .padding()

            Spacer()

            Text("Built with SwiftUI for macOS 14+")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}
