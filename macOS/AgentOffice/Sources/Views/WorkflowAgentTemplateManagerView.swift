// WorkflowAgentTemplateManagerView.swift
import SwiftUI

struct WorkflowAgentTemplateManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""

    private let templates: [(String, String, String, Int)] = [
        ("Parallel Research", "Research topics in parallel", "parallel", 2),
        ("Code Review", "Multi-agent code review", "review", 3),
        ("Pipeline Build", "Sequential build stages", "pipeline", 4),
        ("Debate Analysis", "Competing perspectives", "debate", 3),
        ("Quality Gate", "Automated quality checks", "quality-gate", 2),
        ("Synthesis Merge", "Merge multiple outputs", "synthesis", 3),
        ("Conditional Flow", "Branching logic workflow", "conditional", 2),
        ("Collaboration", "Shared context agents", "collab", 4),
    ]

    private var filteredTemplates: [(String, String, String, Int)] {
        searchText.isEmpty ? templates : templates.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Template Manager").font(.headline)
                Spacer()
                Text("\(templates.count) templates")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search templates...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.vertical, 6)

            Divider()

            List {
                ForEach(filteredTemplates.indices, id: \.self) { i in
                    TemplateManagerRow(
                        name: filteredTemplates[i].0,
                        description: filteredTemplates[i].1,
                        mode: filteredTemplates[i].2,
                        agents: filteredTemplates[i].3
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Create New") {
                    store.showToast("New template created", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}

// MARK: - Template Manager Row
struct TemplateManagerRow: View {
    let name: String
    let description: String
    let mode: String
    let agents: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.text.fill")
                .foregroundStyle(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(agents) agents")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(mode)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.15), in: Capsule())
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }
}
