// WorkflowAgentAgentAvailabilityView.swift
import SwiftUI

struct WorkflowAgentAgentAvailabilityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, String, Int, Color)] = [
        ("Architect", "Available", 85, .green),
        ("Builder", "Busy", 92, .orange),
        ("Reviewer", "Available", 78, .green),
        ("Tester", "Busy", 88, .orange),
        ("Planner", "Available", 65, .green),
        ("Security", "Offline", 0, .red),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Availability").font(.headline)
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
                AvailabilityStatPill(label: "Available", value: "3", color: .green)
                AvailabilityStatPill(label: "Busy", value: "2", color: .orange)
                AvailabilityStatPill(label: "Offline", value: "1", color: .red)
                AvailabilityStatPill(label: "Avg Load", value: "68%", color: .blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(agents.indices, id: \.self) { i in
                        AvailabilityStatusRow(
                            name: agents[i].0,
                            status: agents[i].1,
                            load: agents[i].2,
                            color: agents[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Refresh") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 440, height: 420)
    }
}

// MARK: - Stat Pill
struct AvailabilityStatPill: View {
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

// MARK: - Availability Row
struct AvailabilityStatusRow: View {
    let name: String
    let status: String
    let load: Int
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            Text(status)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(color.opacity(0.15), in: Capsule())
                .foregroundStyle(color)
            Spacer()
            ProgressView(value: Double(load) / 100.0)
                .frame(width: 100)
                .tint(color)
            Text("\(load)%")
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 35, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}