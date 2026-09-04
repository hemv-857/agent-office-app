// ActivityLogView.swift
import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var filter = ""

    var filtered: [ActivityEntry] {
        if filter.isEmpty { return store.activityLog }
        return store.activityLog.filter { $0.message.localizedCaseInsensitiveContains(filter) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Activity Log").font(.headline)
                Spacer()
                if !store.activityLog.isEmpty {
                    Button("Clear") { store.activityLog = []; store.showActivityBadge = false }
                        .font(.caption)
                }
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").font(.system(size: 10)).foregroundStyle(.secondary)
                TextField("Filter...", text: $filter).textFieldStyle(.plain)
            }
            .padding(6).background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 10).padding(.bottom, 8)

            Divider()

            List(filtered.reversed()) { entry in
                HStack(spacing: 8) {
                    Circle().fill(color(entry.type)).frame(width: 6, height: 6)
                    Text(entry.message).font(.system(size: 12))
                    Spacer()
                    Text(entry.timestamp, style: .time).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 450, height: 400)
    }

    func color(_ type: ActivityType) -> Color {
        switch type {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
