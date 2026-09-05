// WebhookConfigView.swift
import SwiftUI

struct WebhookConfigView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var webhooks: [WebhookService.Webhook] = []
    @State private var showingAddWebhook = false
    @State private var newWebhookName = ""
    @State private var newWebhookURL = ""
    @State private var newWebhookEvents: Set<WebhookService.WebhookEvent> = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Webhooks").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Webhook list
            if webhooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "link").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No webhooks configured").foregroundStyle(.secondary)
                    Text("Add webhooks to receive notifications")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(webhooks) { webhook in
                        WebhookRow(webhook: webhook) {
                            toggleWebhook(webhook)
                        } onDelete: {
                            deleteWebhook(webhook)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Add Webhook") { showingAddWebhook = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingAddWebhook) {
            AddWebhookView(
                name: $newWebhookName,
                url: $newWebhookURL,
                events: $newWebhookEvents,
                onSave: addWebhook
            )
        }
        .onAppear {
            webhooks = WebhookService.shared.webhooks
        }
    }

    func addWebhook() {
        let webhook = WebhookService.Webhook(
            id: UUID().uuidString,
            name: newWebhookName,
            url: newWebhookURL,
            events: Array(newWebhookEvents),
            isActive: true
        )
        WebhookService.shared.registerWebhook(webhook)
        webhooks = WebhookService.shared.webhooks
        newWebhookName = ""
        newWebhookURL = ""
        newWebhookEvents = []
        showingAddWebhook = false
    }

    func toggleWebhook(_ webhook: WebhookService.Webhook) {
        if let index = webhooks.firstIndex(where: { $0.id == webhook.id }) {
            webhooks[index].isActive.toggle()
        }
    }

    func deleteWebhook(_ webhook: WebhookService.Webhook) {
        WebhookService.shared.unregisterWebhook(id: webhook.id)
        webhooks = WebhookService.shared.webhooks
    }
}

// MARK: - Webhook Row
struct WebhookRow: View {
    let webhook: WebhookService.Webhook
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(webhook.name).font(.system(size: 12, weight: .medium))
                    if webhook.failureCount > 0 {
                        Text("(\(webhook.failureCount) failures)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                Text(webhook.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    ForEach(webhook.events, id: \.self) { event in
                        Text(event.rawValue)
                            .font(.system(size: 8))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
                    }
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { webhook.isActive },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Webhook View
struct AddWebhookView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var url: String
    @Binding var events: Set<WebhookService.WebhookEvent>
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Webhook").font(.headline)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("URL", text: $url)
                .textFieldStyle(.roundedBorder)

            Text("Events:").font(.system(size: 11, weight: .medium))
            ForEach(WebhookService.WebhookEvent.allCases, id: \.self) { event in
                Toggle(event.rawValue, isOn: Binding(
                    get: { events.contains(event) },
                    set: { _ in
                        if events.contains(event) {
                            events.remove(event)
                        } else {
                            events.insert(event)
                        }
                    }
                ))
                .toggleStyle(.checkbox)
            }

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || url.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
