// SystemInfoBar.swift
import SwiftUI

struct SystemInfoBar: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var performanceMonitor = PerformanceMonitor.shared
    @StateObject private var cacheManager = CacheManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // Memory
            HStack(spacing: 4) {
                Image(systemName: "memorychip")
                    .font(.system(size: 9))
                Text("\(performanceMonitor.metrics.memoryUsage / 1024 / 1024) MB")
                    .font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(.secondary)

            // CPU
            HStack(spacing: 4) {
                Image(systemName: "cpu")
                    .font(.system(size: 9))
                Text(String(format: "%.1f%%", performanceMonitor.metrics.cpuUsage))
                    .font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(.secondary)

            Divider().frame(height: 12)

            // API calls
            HStack(spacing: 4) {
                Image(systemName: "network")
                    .font(.system(size: 9))
                Text("\(performanceMonitor.metrics.totalAPICalls) calls")
                    .font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(.secondary)

            // Cache
            HStack(spacing: 4) {
                Image(systemName: "internaldrive")
                    .font(.system(size: 9))
                Text("\(cacheManager.cacheStats.hitCount) hits")
                    .font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(.secondary)

            Spacer()

            // Provider
            Text(store.selectedProvider.rawValue.capitalized)
                .font(.system(size: 9, weight: .medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.quaternary, in: Capsule())

            // Agent count
            HStack(spacing: 4) {
                Image(systemName: "person.3")
                    .font(.system(size: 9))
                Text("\(store.allAgents.count)")
                    .font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
