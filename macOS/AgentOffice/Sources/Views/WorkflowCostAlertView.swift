// WorkflowCostAlertView.swift
import SwiftUI

struct WorkflowCostAlertView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var threshold = 0.05

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Alert").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                // Warning icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)

                Text("High Cost Warning")
                    .font(.title3)

                Text("Your current session has exceeded the cost threshold.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Current cost
                VStack(spacing: 8) {
                    HStack {
                        Text("Current cost:")
                        Spacer()
                        Text(String(format: "$%.4f", store.todayCost))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    HStack {
                        Text("Threshold:")
                        Spacer()
                        Text(String(format: "$%.4f", threshold))
                            .font(.system(size: 12, design: .monospaced))
                    }
                }
                .font(.system(size: 11))
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                // Actions
                HStack(spacing: 12) {
                    Button("Continue") { dismiss() }
                        .buttonStyle(.bordered)
                    Button("Stop Session") {
                        store.cancelRun()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 380)
    }
}
