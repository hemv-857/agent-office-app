// WorkflowSystemPreferencesView.swift
import SwiftUI

struct WorkflowSystemPreferencesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var startupBehavior = "lastSession"
    @State private var windowRestore = true
    @State private var launchAtLogin = false
    @State private var checkUpdates = true
    @State private var telemetryEnabled = false
    @State private var language = "English"
    @State private var dateFormat = "MMM d, yyyy"
    @State private var timeFormat = "h:mm a"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Preferences").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Startup
                    GroupBox("Startup") {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("On launch:", selection: $startupBehavior) {
                                Text("Show last session").tag("lastSession")
                                Text("Show empty office").tag("empty")
                                Text("Show quick start").tag("quickStart")
                            }
                            Toggle("Restore window position", isOn: $windowRestore)
                            Toggle("Launch at login", isOn: $launchAtLogin)
                        }
                        .padding(8)
                    }

                    // Updates
                    GroupBox("Updates") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Check for updates automatically", isOn: $checkUpdates)
                            Toggle("Send anonymous telemetry", isOn: $telemetryEnabled)
                            HStack {
                                Text("Current version:")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundStyle(.secondary)
                                Button("Check Now") {}
                                    .buttonStyle(.bordered)
                            }
                        }
                        .padding(8)
                    }

                    // Localization
                    GroupBox("Localization") {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Language", selection: $language) {
                                Text("English").tag("English")
                                Text("Spanish").tag("Spanish")
                                Text("French").tag("French")
                                Text("German").tag("German")
                                Text("Japanese").tag("Japanese")
                                Text("Chinese").tag("Chinese")
                            }
                            Picker("Date format", selection: $dateFormat) {
                                Text("MMM d, yyyy").tag("MMM d, yyyy")
                                Text("d/MM/yyyy").tag("d/MM/yyyy")
                                Text("yyyy-MM-dd").tag("yyyy-MM-dd")
                            }
                            Picker("Time format", selection: $timeFormat) {
                                Text("h:mm a").tag("h:mm a")
                                Text("HH:mm").tag("HH:mm")
                            }
                        }
                        .padding(8)
                    }

                    // Performance
                    GroupBox("Performance") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Reduce animations", isOn: .constant(false))
                            Toggle("Hardware acceleration", isOn: .constant(true))
                            Toggle("Background processing", isOn: .constant(true))
                            HStack {
                                Text("Cache size:")
                                Slider(value: .constant(0.5), in: 0...1)
                                Text("50 MB")
                                    .foregroundStyle(.secondary)
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
                Button("Reset All") {
                    store.showToast("Preferences reset to defaults", type: .info)
                }
                .buttonStyle(.bordered)
                Button("Done") {
                    store.showToast("Preferences saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}
