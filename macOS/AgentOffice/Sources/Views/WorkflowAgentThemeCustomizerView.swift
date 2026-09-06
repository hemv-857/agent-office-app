// WorkflowAgentThemeCustomizerView.swift
import SwiftUI

struct WorkflowAgentThemeCustomizerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedTheme = "light"
    @State private var accentColor = "blue"

    private let themes = ["light", "dark", "auto"]
    private let accentColors = ["blue", "purple", "green", "orange", "red"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Theme Customizer").font(.headline)
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
                    GroupBox("Appearance") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Theme:").font(.system(size: 11, weight: .medium))
                            Picker("", selection: $selectedTheme) {
                                ForEach(themes, id: \.self) { Text($0.capitalized) }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                        .padding(8)
                    }

                    GroupBox("Accent Color") {
                        HStack(spacing: 12) {
                            ForEach(accentColors, id: \.self) { color in
                                Circle()
                                    .fill(Color(color == "blue" ? .blue : color == "purple" ? .purple : color == "green" ? .green : color == "orange" ? .orange : .red))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle().stroke(.white, lineWidth: accentColor == color ? 3 : 0)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 2)
                                    .onTapGesture { withAnimation { accentColor = color } }
                            }
                        }
                        .padding(8)
                    }

                    GroupBox("Preview") {
                        HStack {
                            Button("Primary") {}
                                .buttonStyle(.borderedProminent)
                            Button("Secondary") {}
                                .buttonStyle(.bordered)
                            Text("Sample text")
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Save") {
                    store.showToast("Theme saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 400, height: 440)
    }
}
