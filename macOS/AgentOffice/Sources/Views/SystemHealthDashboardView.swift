// SystemHealthDashboardView.swift
import SwiftUI

struct SystemHealthDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @StateObject private var perf = PerformanceMonitor.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Health").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // CPU & Memory
                    HStack(spacing: 12) {
                        HealthGauge(title: "CPU", value: perf.metrics.cpuUsage, unit: "%", color: perf.metrics.cpuUsage > 80 ? .red : .green)
                        HealthGauge(title: "Memory", value: Double(perf.metrics.memoryUsage) / 1_000_000, unit: "MB", color: perf.metrics.memoryUsage > 500_000_000 ? .orange : .green)
                    }

                    // API & Cache
                    HStack(spacing: 12) {
                        HealthStat(title: "API Calls", value: "\(perf.metrics.totalAPICalls)", icon: "arrow.up.arrow.down")
                        HealthStat(title: "Cache Hits", value: "\(CacheManager.shared.cacheStats.hitCount)", icon: "checkmark.circle")
                        HealthStat(title: "Cache Misses", value: "\(CacheManager.shared.cacheStats.missCount)", icon: "xmark.circle")
                    }

                    // Provider status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Provider Status").font(.system(size: 12, weight: .semibold))
                        ForEach(LLMProvider.allCases, id: \.self) { provider in
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 6, height: 6)
                                Text(provider.displayName)
                                    .font(.system(size: 11))
                                Spacer()
                                Text(store.apiKey.isEmpty ? "Not set" : "Configured")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Uptime
                    HStack {
                        Text("Uptime")
                        Spacer()
                        Text(formattedUptime)
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .font(.system(size: 11))
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
        .frame(width: 480, height: 480)
    }

    private var formattedUptime: String {
        let seconds = Int(Date().timeIntervalSince1970) % 86400
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return "\(h)h \(m)m"
    }
}

// MARK: - Health Gauge
struct HealthGauge: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title).font(.system(size: 10, weight: .semibold))
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(value / 100, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(String(format: "%.0f", value))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            .frame(width: 60, height: 60)
            Text(unit)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Health Stat
struct HealthStat: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
