// WorkflowQuickSetupView.swift
import SwiftUI

struct WorkflowQuickSetupView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var setupStep = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Setup").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                // Step indicator
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i <= setupStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                switch setupStep {
                case 0:
                    VStack(spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                        Text("Set API Key")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Configure your LLM provider API key")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                case 1:
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                        Text("Select Agents")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Choose agents for your workspace")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                case 2:
                    VStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                        Text("Ready to Go")
                            .font(.system(size: 14, weight: .semibold))
                        Text("You're all set to start using Agent Office")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)

            Spacer()

            Divider()

            HStack {
                if setupStep > 0 {
                    Button("Back") { setupStep -= 1 }
                        .buttonStyle(.bordered)
                }
                Spacer()
                if setupStep < 2 {
                    Button("Next") { setupStep += 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Finish") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 380)
    }
}
