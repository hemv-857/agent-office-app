// CostAlertConfigurationView.swift
import SwiftUI

struct CostAlertConfigurationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @AppStorage("costAlertEnabled") private var alertEnabled = true
    @AppStorage("costAlertThreshold") private var threshold = 5.0
    @AppStorage("costAlertDaily") private var dailyBudget = 10.0
    @AppStorage("costAlertNotify") private var notify = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Alerts").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Enable alerts
                    Toggle("Enable cost alerts", isOn: $alertEnabled)

                    if alertEnabled {
                        // Daily budget
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily Budget").font(.system(size: 12, weight: .semibold))
                            HStack {
                                Text("$")
                                TextField("10.00", value: $dailyBudget, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                            }
                            Text("Alert when daily spending exceeds this amount")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Threshold alert
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Per-Request Threshold").font(.system(size: 12, weight: .semibold))
                            HStack {
                                Text("$")
                                TextField("5.00", value: $threshold, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                            }
                            Text("Alert when a single request exceeds this cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Notification
                        Toggle("Show desktop notifications", isOn: $notify)

                        // Current status
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Status").font(.system(size: 12, weight: .semibold))
                            HStack {
                                Text("Today's spending:")
                                Spacer()
                                Text(String(format: "$%.2f", store.todayCost))
                                    .font(.system(size: 11, design: .monospaced))
                            }
                            ProgressView(value: store.todayCost, total: dailyBudget)
                                .tint(store.todayCost > dailyBudget ? .red : .green)
                            HStack {
                                Text("Remaining:")
                                Spacer()
                                Text(String(format: "$%.2f", max(0, dailyBudget - store.todayCost)))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(store.todayCost > dailyBudget ? .red : .green)
                            }
                        }
                        .padding()
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 450)
    }
}
