// WorkflowAgentAgentTemplateCategoriesView.swift
import SwiftUI

struct WorkflowAgentAgentTemplateCategoriesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let categories: [(String, String, Int, Color, [String])] = [
        ("Development", "Code implementation and refactoring", 12, .blue, ["Feature", "Refactor", "Bug Fix", "API"]),
        ("Review", "Code review and quality checks", 8, .green, ["Code Review", "Security", "Performance", "Architecture"]),
        ("Testing", "Test generation and execution", 6, .orange, ["Unit", "Integration", "E2E", "Performance"]),
        ("Documentation", "Docs generation and updates", 5, .purple, ["API Docs", "README", "Changelog", "Comments"]),
        ("Planning", "Sprint and feature planning", 4, .cyan, ["Sprint", "Roadmap", "Estimation", "Retro"]),
        ("DevOps", "Deployment and infrastructure", 3, .red, ["Deploy", "CI/CD", "Monitoring", "Scaling"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Template Categories").font(.headline)
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
                    ForEach(categories.indices, id: \.self) { i in
                        TemplateCategoryRow(
                            name: categories[i].0,
                            description: categories[i].1,
                            count: categories[i].2,
                            color: categories[i].3,
                            templates: categories[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Manage Templates") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 460)
    }
}

// MARK: - Template Category Row
struct TemplateCategoryRow: View {
    let name: String
    let description: String
    let count: Int
    let color: Color
    let templates: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 12, weight: .semibold))
                    Text(description)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(count) templates")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(templates, id: \.self) { template in
                        Text(template)
                            .font(.system(size: 8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(color.opacity(0.2), in: Capsule())
                            .foregroundStyle(color)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}