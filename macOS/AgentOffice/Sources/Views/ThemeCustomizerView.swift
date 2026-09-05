// ThemeCustomizerView.swift
import SwiftUI

struct ThemeCustomizerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @AppStorage("accentColor") private var accentColorHex: String = "#007AFF"
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("reduceMotion") private var reduceMotion = false

    private let presetColors: [(String, Color)] = [
        ("Blue", .blue), ("Purple", .purple), ("Green", .green),
        ("Orange", .orange), ("Red", .red), ("Pink", .pink),
        ("Teal", .teal), ("Indigo", .indigo),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Customize Theme").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Theme mode
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theme Mode").font(.system(size: 12, weight: .semibold))
                        Picker("Theme", selection: $store.theme) {
                            ForEach(Theme.allCases, id: \.self) { theme in
                                Text(theme.rawValue.capitalized).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Accent color
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accent Color").font(.system(size: 12, weight: .semibold))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                            ForEach(presetColors, id: \.0) { colorPair in
                                Button(action: {
                                    accentColorHex = colorPair.0
                                }) {
                                    Circle()
                                        .fill(colorPair.1)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: accentColorHex == colorPair.0 ? 3 : 0)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Animations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Animations").font(.system(size: 12, weight: .semibold))
                        Toggle("Enable animations", isOn: $animationsEnabled)
                        Toggle("Reduce motion", isOn: $reduceMotion)
                    }

                    // Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview").font(.system(size: 12, weight: .semibold))
                        HStack {
                            Button("Primary") {}
                                .buttonStyle(.borderedProminent)
                            Button("Secondary") {}
                                .buttonStyle(.bordered)
                            Button("Destructive") {}
                                .buttonStyle(.bordered)
                                .foregroundStyle(.red)
                        }
                        Text("Sample text with current settings applied.")
                            .font(.system(size: 12))
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 450, height: 500)
    }
}
