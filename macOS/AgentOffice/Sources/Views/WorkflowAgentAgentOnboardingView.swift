// WorkflowAgentAgentOnboardingView.swift
import SwiftUI

struct WorkflowAgentAgentOnboardingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var step = 0

    private let steps: [(String, String, String)] = [
        ("Welcome to Agent Office", "Your AI-powered multi-agent workspace", "arrow.right"),
        ("Choose Your Agents", "Select agents from the sidebar to assign to desks", "person.3"),
        ("Write a Prompt", "Type your task in the chat input and press Enter", "pencil"),
        ("Watch Them Work", "Agents collaborate in parallel to complete your task", "play.circle"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Onboarding").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(i <= step ? .blue : .gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 16)

            // Content
            VStack(spacing: 12) {
                Image(systemName: steps[step].2)
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                    .padding(.top, 20)
                Text(steps[step].0)
                    .font(.system(size: 18, weight: .bold))
                Text(steps[step].1)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            HStack {
                if step > 0 {
                    Button("Back") { step -= 1 }
                        .buttonStyle(.bordered)
                }
                Spacer()
                if step < 3 {
                    Button("Next") { step += 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 440, height: 360)
    }
}
