// WorkflowSkillTreeVisualizerView.swift
import SwiftUI

struct WorkflowSkillTreeVisualizerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory = "Engineering"

    private let categories: [String: [(String, Int, [String])]] = [
        "Engineering": [
            ("Swift", 95, ["Concurrency", "SwiftUI", "Combine", "CoreData"]),
            ("Python", 88, ["FastAPI", "Django", "ML", "Data Science"]),
            ("TypeScript", 90, ["React", "Node.js", "Next.js", "Prisma"]),
            ("Go", 82, ["Goroutines", "gRPC", "Docker", "Kubernetes"]),
            ("Rust", 75, ["Ownership", "Async", "WASM", "CLI"]),
        ],
        "Writing": [
            ("Technical Writing", 92, ["Docs", "API Guides", "Tutorials"]),
            ("Copywriting", 85, ["Marketing", "Landing Pages", "Emails"]),
            ("Creative Writing", 78, ["Fiction", "Screenplays", "Poetry"]),
        ],
        "Analysis": [
            ("Data Analysis", 90, ["Pandas", "SQL", "Visualization"]),
            ("Market Research", 85, ["Competitive Analysis", "Surveys"]),
            ("Financial Modeling", 72, ["Excel", "Python", "Forecasting"]),
        ],
        "Design": [
            ("UI Design", 88, ["Figma", "Sketch", "Prototyping"]),
            ("UX Research", 82, ["User Interviews", "A/B Testing"]),
            ("Motion Design", 70, ["After Effects", "Lottie", "CSS Animations"]),
        ],
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Skill Tree").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Category picker
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(categories.keys.sorted(), id: \.self) { cat in
                        Text(cat)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedCategory == cat ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedCategory == cat ? .white : .primary)
                            .onTapGesture { selectedCategory = cat }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            Divider()

            // Skills
            ScrollView {
                VStack(spacing: 10) {
                    if let skills = categories[selectedCategory] {
                        ForEach(skills, id: \.0) { skill in
                            SkillBranch(name: skill.0, proficiency: skill.1, subskills: skill.2)
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                let totalSkills = categories.values.flatMap { $0 }.count
                Text("\(totalSkills) skills across \(categories.count) categories")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 520)
    }
}

// MARK: - Skill Branch
struct SkillBranch: View {
    let name: String
    let proficiency: Int
    let subskills: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text("\(proficiency)%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(proficiency >= 90 ? .green : proficiency >= 75 ? .blue : .orange)
            }
            ProgressView(value: Double(proficiency) / 100.0)
                .tint(proficiency >= 90 ? .green : proficiency >= 75 ? .blue : .orange)

            // Subskills as tags
            FlowLayout(spacing: 4) {
                ForEach(subskills, id: \.self) { sub in
                    Text(sub)
                        .font(.system(size: 9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
            }
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Simple Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX)
        }

        return (CGSize(width: totalWidth, height: currentY + lineHeight), positions)
    }
}
