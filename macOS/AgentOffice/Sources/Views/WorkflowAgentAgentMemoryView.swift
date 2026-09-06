// WorkflowAgentAgentMemoryView.swift
import SwiftUI

struct WorkflowAgentAgentMemoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, Int, Int, Int, [String])] = [
        ("Architect", 142, 89, 23, ["Design patterns", "System constraints", "API contracts"]),
        ("Builder", 289, 234, 45, ["Implementation patterns", "Code templates", "Bug fixes"]),
        ("Reviewer", 167, 98, 32, ["Code standards", "Security patterns", "Performance tips"]),
        ("Tester", 98, 67, 18, ["Test strategies", "Edge cases", "Flaky tests"]),
        ("Planner", 76, 54, 12, ["Sprint patterns", "Estimation rules", "Dependencies"]),
        ("Security", 45, 38, 8, ["Vulnerability patterns", "Compliance rules", "Audit trails"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Memory").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                MemoryStatPill(label: "Total Memories", value: "817", color: .blue)
                MemoryStatPill(label: "Shared", value: "580", color: .green)
                MemoryStatPill(label: "Private", value: "146", color: .orange)
                MemoryStatPill(label: "Archived", value: "91", color: .gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(agents.indices, id: \.self) { i in
                        MemoryAgentRow(
                            name: agents[i].0,
                            total: agents[i].1,
                            shared: agents[i].2,
                            privateCount: agents[i].3,
                            tags: agents[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Consolidate") {
                    store.showToast("Memory consolidated", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Clear Archived") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 460)
    }
}

// MARK: - Stat Pill
struct MemoryStatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Memory Agent Row
struct MemoryAgentRow: View {
    let name: String
    let total: Int
    let shared: Int
    let privateCount: Int
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text("\(total) items")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Label("\(shared) shared", systemImage: "person.2")
                    .font(.system(size: 9))
                    .foregroundStyle(.green)
                Label("\(privateCount) private", systemImage: "lock")
                    .font(.system(size: 9))
                    .foregroundStyle(.orange)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: Capsule())
                    }
                }
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}