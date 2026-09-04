// WorkflowLogView.swift
import SwiftUI

struct WorkflowLogView: View {
    @EnvironmentObject var store: AppStore
    @State private var autoScroll = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Log").font(.headline)
                Spacer()
                Toggle(isOn: $autoScroll) {
                    Text("Auto-scroll").font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                if store.isRunning {
                    HStack(spacing: 4) {
                        ProgressView().controlSize(.mini)
                        Text("Running").font(.caption).foregroundStyle(.blue)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(store.activityLog.prefix(50)) { entry in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(color(entry.type))
                                    .frame(width: 6, height: 6)
                                    .offset(y: 4)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(entry.message)
                                        .font(.system(size: 11, design: .monospaced))
                                    Text(entry.timestamp, style: .time)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.tertiary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 2)
                            .id(entry.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: store.activityLog.count) { _ in
                    if autoScroll, let last = store.activityLog.first {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
        }
        .frame(width: 350, height: 300)
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
