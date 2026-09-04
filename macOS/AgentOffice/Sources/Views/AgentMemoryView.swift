// AgentMemoryView.swift
import SwiftUI

struct AgentMemoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

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

            if store.agentMemory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "brain").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No memories yet").foregroundStyle(.secondary)
                    Text("Memories are learned from agent interactions").font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.agentMemory.reversed()) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.pattern).font(.system(size: 13, weight: .medium))
                            Spacer()
                            Text(String(format: "%.0f%%", entry.confidence * 100))
                                .font(.caption).foregroundStyle(.green)
                        }
                        Text(entry.context).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        Text(entry.timestamp, style: .relative).font(.caption2).foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .frame(width: 450, height: 400)
    }
}
