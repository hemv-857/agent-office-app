// AgentSkillTreeView.swift
import SwiftUI

struct AgentSkillTreeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let skillTree: [(String, [String])] = [
        ("Engineering", ["Code Review", "Architecture", "Testing", "Debugging"]),
        ("Writing", ["Documentation", "Blog Posts", "Technical Writing", "Editing"]),
        ("Analysis", ["Data Analysis", "Research", "Market Analysis", "Forecasting"]),
        ("Design", ["UI/UX", "Brand Identity", "Motion Design", "Illustration"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Skills").font(.headline)
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
                    ForEach(skillTree, id: \.0) { category, skills in
                        SkillCategorySection(category: category, skills: skills)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Categories: \(skillTree.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 450)
    }
}

// MARK: - Skill Category Section
struct SkillCategorySection: View {
    let category: String
    let skills: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconForCategory(category))
                    .foregroundStyle(.blue)
                Text(category)
                    .font(.system(size: 12, weight: .semibold))
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 6) {
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                        .font(.system(size: 10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Engineering": return "hammer.fill"
        case "Writing": return "pencil.and.outline"
        case "Analysis": return "chart.bar.fill"
        case "Design": return "paintbrush.fill"
        default: return "star.fill"
        }
    }
}
