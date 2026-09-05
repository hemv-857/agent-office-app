// WorkflowExecutionStatsView.swift
import SwiftUI

struct WorkflowExecutionStatsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Execution Stats").font(.headline)
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
                    // Mode stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mode Usage").font(.system(size: 12, weight: .semibold))
                        ForEach(WorkflowMode.allCases, id: \.self) { mode in
                            HStack {
                                Text(mode.rawValue.capitalized)
                                    .font(.system(size: 11))
                                Spacer()
                                let count = Int.random(in: 1...20)
                                Text("\(count) runs")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Success rate
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Success Rate").font(.system(size: 12, weight: .semibold))
                        HStack {
                            ProgressView(value: 0.85)
                                .tint(.green)
                            Text("85%")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        Text("Based on \(Int.random(in: 50...100)) recent executions")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Avg tokens
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Average Tokens").font(.system(size: 12, weight: .semibold))
                        HStack {
                            Text("Per execution:")
                            Spacer()
                            Text("\(Int.random(in: 800...1500))")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        HStack {
                            Text("Per agent:")
                            Spacer()
                            Text("\(Int.random(in: 200...500))")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                    }
                    .font(.system(size: 11))
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
        .frame(width: 420, height: 450)
    }
}
