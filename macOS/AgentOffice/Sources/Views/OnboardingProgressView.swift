// OnboardingProgressView.swift
import SwiftUI

struct OnboardingProgressView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @AppStorage("onboardingStep") private var currentStep = 0

    private let steps: [(String, String)] = [
        ("Welcome", "wave"),
        ("API Key", "key"),
        ("Select Provider", "cpu"),
        ("Choose Agents", "person.3"),
        ("First Prompt", "text.alignleft"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Getting Started").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Progress bar
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Rectangle()
                            .fill(index <= currentStep ? Color.accentColor : Color(nsColor: .separatorColor))
                            .frame(height: 4)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))

                // Steps
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(index <= currentStep ? Color.accentColor : Color(nsColor: .separatorColor))
                                .frame(width: 28, height: 28)
                            if index < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.0)
                                .font(.system(size: 12, weight: index == currentStep ? .semibold : .regular))
                            if index == currentStep {
                                Text(stepDescription(index))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if index == currentStep {
                            Image(systemName: step.1)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                if currentStep > 0 {
                    Button("Back") { currentStep -= 1 }
                        .buttonStyle(.bordered)
                }
                Spacer()
                if currentStep < steps.count - 1 {
                    Button("Next") { currentStep += 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 420, height: 400)
    }

    func stepDescription(_ index: Int) -> String {
        switch index {
        case 0: return "Welcome to Agent Office"
        case 1: return "Set up your API key"
        case 2: return "Choose your LLM provider"
        case 3: return "Pick your AI agents"
        case 4: return "Write your first prompt"
        default: return ""
        }
    }
}
