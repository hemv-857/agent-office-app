// WorkflowNotificationsCenterView.swift
import SwiftUI

struct WorkflowNotificationsCenterView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var notifications: [(Date, String, String, Bool)] = [
        (Date().addingTimeInterval(-60), "Task Completed", "Architect finished system design", false),
        (Date().addingTimeInterval(-300), "Budget Alert", "Daily budget at 80%", false),
        (Date().addingTimeInterval(-600), "Agent Offline", "Ollama server unreachable", true),
        (Date().addingTimeInterval(-900), "New Update", "App version 1.1.0 available", false),
        (Date().addingTimeInterval(-1800), "Backup Complete", "Auto-backup completed successfully", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Notifications").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filter
            HStack {
                Button("All") {}
                    .buttonStyle(.bordered)
                Button("Unread") {}
                    .buttonStyle(.bordered)
                Spacer()
                Button("Mark All Read") {
                    for i in notifications.indices {
                        notifications[i].3 = true
                    }
                }
                .buttonStyle(.bordered)
                .font(.system(size: 10))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Notification list
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(notifications.indices, id: \.self) { index in
                        NotificationRow(
                            date: notifications[index].0,
                            title: notifications[index].1,
                            message: notifications[index].2,
                            isRead: notifications[index].3,
                            onToggle: { notifications[index].3.toggle() }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(notifications.filter { !$0.3 }.count) unread")
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

// MARK: - Notification Row
struct NotificationRow: View {
    let date: Date
    let title: String
    let message: String
    let isRead: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isRead ? Color.gray.opacity(0.3) : .blue)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 11, weight: isRead ? .regular : .semibold))
                    Spacer()
                    Text(date, style: .relative)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(isRead ? .clear : Color.blue.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
        .onTapGesture { onToggle() }
    }
}
