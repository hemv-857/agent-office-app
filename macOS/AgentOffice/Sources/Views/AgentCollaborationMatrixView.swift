// AgentCollaborationMatrixView.swift
import SwiftUI

struct AgentCollaborationMatrixView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Arch", "Build", "Rev", "Test", "Plan"]
    private let matrix: [[Double]] = [
        [1.0, 0.9, 0.3, 0.2, 0.8],
        [0.9, 1.0, 0.7, 0.6, 0.4],
        [0.3, 0.7, 1.0, 0.5, 0.3],
        [0.2, 0.6, 0.5, 1.0, 0.2],
        [0.8, 0.4, 0.3, 0.2, 1.0],
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Collaboration Matrix").font(.headline)
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
                    // Matrix grid
                    VStack(spacing: 0) {
                        // Header
                        HStack(spacing: 0) {
                            Text("").frame(width: 40)
                            ForEach(agents, id: \.self) { agent in
                                Text(agent)
                                    .font(.system(size: 8, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom, 4)

                        // Rows
                        ForEach(agents.indices, id: \.self) { row in
                            HStack(spacing: 0) {
                                Text(agents[row])
                                    .font(.system(size: 8, weight: .medium))
                                    .frame(width: 40, alignment: .leading)
                                ForEach(agents.indices, id: \.self) { col in
                                    let value = matrix[row][col]
                                    Rectangle()
                                        .fill(cellColor(value))
                                        .frame(height: 24)
                                        .overlay(
                                            Text(String(format: "%.0f", value * 100))
                                                .font(.system(size: 7, design: .monospaced))
                                                .foregroundStyle(.white)
                                        )
                                }
                            }
                        }
                    }

                    // Legend
                    HStack(spacing: 8) {
                        ForEach(0..<5) { i in
                            let value = Double(i) / 4.0
                            Rectangle()
                                .fill(cellColor(value))
                                .frame(width: 16, height: 10)
                            Text("\(Int(value * 100))%")
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 8)
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

    private func cellColor(_ value: Double) -> Color {
        if value > 0.8 { return .green }
        if value > 0.6 { return .yellow }
        if value > 0.4 { return .orange }
        return .red.opacity(0.6)
    }
}
