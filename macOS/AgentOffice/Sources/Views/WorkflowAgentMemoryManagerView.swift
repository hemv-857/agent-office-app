// WorkflowAgentMemoryManagerView.swift
import SwiftUI

struct WorkflowAgentMemoryManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedAgent = "Architect"
    @State private var searchText = ""

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    private let memories: [(String, String, String, Date, Bool)] = [
        ("Architect", "Microservice boundaries", "Prefer domain-driven bounded contexts over technical splits", Date().addingTimeInterval(-3600), false),
        ("Architect", "API versioning strategy", "Use URL-based versioning (/v1/, /v2/) for public APIs", Date().addingTimeInterval(-7200), false),
        ("Builder", "Error handling pattern", "Always wrap service calls in do-catch with specific error types", Date().addingTimeInterval(-10800), true),
        ("Builder", "Logging convention", "Use os.Logger with subsystem=com.agent-office, category=agent name", Date().addingTimeInterval(-14400), false),
        ("Reviewer", "Review checklist", "Check error handling, input validation, tests, and documentation", Date().addingTimeInterval(-18000), false),
        ("Reviewer", "Naming conventions", "Use descriptive names, avoid abbreviations in public API", Date().addingTimeInterval(-21600), false),
        ("Tester", "Test data strategy", "Use factories for test data, not raw constructors", Date().addingTimeInterval(-25200), false),
        ("Planner", "Sprint velocity", "Average velocity is 24 story points per sprint", Date().addingTimeInterval(-28800), false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Memory Manager").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Agent picker
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(agents, id: \.self) { agent in
                        Text(agent)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedAgent == agent ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedAgent == agent ? .white : .primary)
                            .onTapGesture { selectedAgent = agent }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Search
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search memories...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal)

            // Memory list
            List {
                ForEach(memories.filter { $0.0 == selectedAgent && (searchText.isEmpty || $0.1.localizedCaseInsensitiveContains(searchText) || $0.2.localizedCaseInsensitiveContains(searchText)) }, id: \.1) { memory in
                    MemoryRow(
                        title: memory.1,
                        content: memory.2,
                        date: memory.3,
                        isFavorite: memory.4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Add Memory") {
                    store.showToast("Memory added", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Memory Row
struct MemoryRow: View {
    let title: String
    let content: String
    let date: Date
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                }
                Text(date, style: .relative)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            Text(content)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
