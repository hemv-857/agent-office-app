// WorkflowAgentAgentSkillMatrixView.swift
import SwiftUI

struct WorkflowAgentAgentSkillMatrixView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let skills = ["Swift", "TypeScript", "Python", "Rust", "SQL", "Docker", "K8s", "AWS", "GraphQL", "Testing"]

    @State private var matrix: [String: [String: Int]] = [:]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Skill Matrix").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Header row
            HStack(spacing: 0) {
                Text("Agent")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .leading)
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(width: 45)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            Divider()

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(agents, id: \.self) { agent in
                        SkillMatrixRow(
                            agent: agent,
                            skills: skills,
                            levels: matrix[agent] ?? [:]
                        )
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                Button("Randomize") { randomize() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 700, height: 440)
        .onAppear { randomize() }
    }

    private func randomize() {
        var newMatrix: [String: [String: Int]] = [:]
        for agent in agents {
            var skills: [String: Int] = [:]
            for skill in self.skills {
                skills[skill] = Int.random(in: 1...5)
            }
            newMatrix[agent] = skills
        }
        matrix = newMatrix
    }
}

// MARK: - Skill Matrix Row
struct SkillMatrixRow: View {
    let agent: String
    let skills: [String]
    let levels: [String: Int]

    var body: some View {
        HStack(spacing: 0) {
            Text(agent)
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            ForEach(skills, id: \.self) { skill in
                let level = levels[skill] ?? 0
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hue: Double(level) * 0.12, saturation: 0.6, brightness: 0.85))
                        .frame(width: 36, height: 20)
                    Text("\(level)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 45)
            }
        }
    }
}