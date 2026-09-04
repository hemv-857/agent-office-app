// HeaderView.swift
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var store: AppStore

    var completedCount: Int {
        store.results.filter { $0.status == .done || $0.status == .error }.count
    }

    var runningCount: Int {
        store.results.filter { $0.status == .working }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: Title + status
            HStack(spacing: 8) {
                // Gradient icon
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                Text("Agent Office")
                    .font(.system(size: 14, weight: .semibold))

                Text(store.seatedDisplay)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())

                // Workflow progress
                if store.isRunning && !store.results.isEmpty {
                    HStack(spacing: 6) {
                        ProgressView(value: Double(completedCount), total: Double(store.results.count))
                            .frame(width: 60)
                        Text("\(completedCount)/\(store.results.count)")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                } else if store.isRunning {
                    HStack(spacing: 4) {
                        ProgressView()
                            .controlSize(.mini)
                        Text("Running")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                }
            }

            Spacer()

            // Right: Controls
            HStack(spacing: 6) {
                // Provider badge
                Text(store.selectedProvider.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())

                // Workflow log
                Button(action: { store.showWorkflowLog = true }) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Workflow Log")
                .badge(store.showActivityBadge ? "!" : nil)

                // Run / Stop
                if store.isRunning {
                    Button(action: store.cancelRun) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                    .help("Stop all agents")
                } else {
                    Button(action: store.runAll) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.green)
                    .help("Run all agents")
                }

                // Toggle results
                Button(action: { store.showResultsPanel.toggle() }) {
                    Image(systemName: store.showResultsPanel ? "sidebar.right" : "sidebar.left")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Toggle results panel")

                // Toggle sidebar
                Button(action: { store.showSidebar.toggle() }) {
                    Image(systemName: store.showSidebar ? "sidebar.left" : "sidebar.left")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Toggle sidebar")

                Divider()
                    .frame(height: 16)

                // Command palette
                Button(action: { store.showCommandPalette = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "command").font(.system(size: 9))
                        Text("K").font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Command Palette (⌘K)")

                // Settings
                Button(action: { store.showSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Settings")

                // Help
                Button(action: { store.showHelp = true }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Help")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.background)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}
