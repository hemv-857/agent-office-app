// WorkflowAppUpdateView.swift
import SwiftUI

struct WorkflowAppUpdateView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Check for Updates").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)

                Text("You're up to date!")
                    .font(.title3)

                Text("Agent Office v1.1.0")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Text("Last checked: Just now")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)

                Button("Check Again") { }
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 380, height: 320)
    }
}
