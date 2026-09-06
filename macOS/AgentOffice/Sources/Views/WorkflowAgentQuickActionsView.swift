// WorkflowAgentQuickActionsView.swift
import SwiftUI

struct WorkflowAgentQuickActionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let actions: [(String, String, String, Color)] = [
        ("Run Pipeline", "Execute a multi-agent pipeline workflow", "bolt.fill", .blue),
        ("Quick Review", "Get instant code review from Reviewer agent", "checkmark.magnifyingglass", .green),
        ("Bug Hunt", "Search for bugs in recent code changes", "ant.fill", .red),
        ("Deploy Check", "Verify deployment readiness", "arrow.up.circle.fill", .teal),
        ("Security Scan", "Run security vulnerability scan", "lock.shield.fill", .orange),
        ("Generate Docs", "Auto-generate documentation for code", "doc.text.fill", .purple),
        ("Cost Report", "Generate cost analysis report", "dollarsign.circle.fill", .green),
        ("Export Data", "Export all session data and results", "square.and.arrow.up.fill", .blue),
    ]

    private let quickPrompts: [(String, String)] = [
        ("Review my latest changes", "reviewer"),
        ("Summarize today's progress", "planner"),
        ("Find potential bugs", "tester"),
        ("Suggest architecture improvements", "architect"),
        ("Check for security issues", "security"),
        ("Optimize API performance", "builder"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Actions").font(.headline)
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
                    // Action buttons
                    GroupBox("Actions") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(actions.indices, id: \.self) { i in
                                QuickActionCard(
                                    title: actions[i].0,
                                    subtitle: actions[i].1,
                                    icon: actions[i].2,
                                    color: actions[i].3
                                )
                            }
                        }
                        .padding(8)
                    }

                    // Quick prompts
                    GroupBox("Quick Prompts") {
                        VStack(spacing: 6) {
                            ForEach(quickPrompts.indices, id: \.self) { i in
                                QuickPromptRow(
                                    prompt: quickPrompts[i].0,
                                    agent: quickPrompts[i].1
                                )
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
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Quick Prompt Row
struct QuickPromptRow: View {
    let prompt: String
    let agent: String

    var body: some View {
        HStack(spacing: 10) {
            Text(prompt)
                .font(.system(size: 11))
            Spacer()
            Text(agent)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.quaternary, in: Capsule())
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
