// DiagnosticsView.swift
import SwiftUI
import SystemConfiguration

struct DiagnosticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var systemInfo: SystemInfo = SystemInfo()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Diagnostics").font(.headline)
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
                    // System info
                    SectionHeader(title: "System", icon: "desktopcomputer")
                    InfoGrid(items: [
                        ("macOS", systemInfo.osVersion),
                        ("Model", systemInfo.modelName),
                        ("CPU", systemInfo.cpuModel),
                        ("Cores", "\(systemInfo.cpuCores)"),
                        ("Memory", systemInfo.totalMemory),
                        ("Uptime", systemInfo.uptime),
                    ])

                    // App info
                    SectionHeader(title: "Application", icon: "app.fill")
                    InfoGrid(items: [
                        ("Version", "1.0.0"),
                        ("Build", "2026.1"),
                        ("Agents", "\(store.allAgents.count)"),
                        ("Desks", "\(store.desks.count)"),
                        ("Results", "\(store.results.count)"),
                        ("Groups", "\(store.groups.count)"),
                        ("Presets", "\(store.presets.count)"),
                    ])

                    // LLM info
                    SectionHeader(title: "LLM Provider", icon: "cpu")
                    InfoGrid(items: [
                        ("Provider", store.selectedProvider.rawValue.capitalized),
                        ("API Key", store.apiKey.isEmpty ? "Not set" : "Set (\(store.apiKey.count) chars)"),
                        ("Budget", String(format: "$%.2f/day", store.dailyBudget)),
                        ("Spent Today", String(format: "$%.2f", store.todayCost)),
                    ])

                    // Performance
                    SectionHeader(title: "Performance", icon: "gauge")
                    InfoGrid(items: [
                        ("Memory Used", "\(PerformanceMonitor.shared.metrics.memoryUsage / 1024 / 1024) MB"),
                        ("CPU Usage", String(format: "%.1f%%", PerformanceMonitor.shared.metrics.cpuUsage)),
                        ("API Calls", "\(PerformanceMonitor.shared.metrics.totalAPICalls)"),
                        ("Cache Hits", "\(CacheManager.shared.cacheStats.hitCount)"),
                        ("Cache Misses", "\(CacheManager.shared.cacheStats.missCount)"),
                    ])
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Copy Diagnostics") {
                    copyDiagnostics()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 550)
        .onAppear {
            systemInfo = SystemInfo()
        }
    }

    func copyDiagnostics() {
        var text = "Agent Office Diagnostics\n"
        text += "========================\n"
        text += "macOS: \(systemInfo.osVersion)\n"
        text += "Model: \(systemInfo.modelName)\n"
        text += "CPU: \(systemInfo.cpuModel)\n"
        text += "Memory: \(systemInfo.totalMemory)\n"
        text += "Provider: \(store.selectedProvider.rawValue)\n"
        text += "API Key: \(store.apiKey.isEmpty ? "Not set" : "Set")\n"
        ClipboardHistoryManager.shared.copyToClipboard(text)
        store.showToast("Diagnostics copied", type: .success)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
            Spacer()
        }
    }
}

// MARK: - Info Grid
struct InfoGrid: View {
    let items: [(String, String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text(item.0)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(item.1)
                        .font(.system(size: 11, design: .monospaced))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                if index < items.count - 1 {
                    Divider().padding(.horizontal, 10)
                }
            }
        }
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - System Info
struct SystemInfo {
    let osVersion: String
    let modelName: String
    let cpuModel: String
    let cpuCores: Int
    let totalMemory: String
    let uptime: String

    init() {
        osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        modelName = Self.getModelName()
        cpuModel = Self.getCPUModel()
        cpuCores = ProcessInfo.processInfo.processorCount
        totalMemory = Self.formatBytes(ProcessInfo.processInfo.physicalMemory)
        uptime = Self.formatUptime(ProcessInfo.processInfo.systemUptime)
    }

    static func getModelName() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }

    static func getCPUModel() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var brand = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
        return String(cString: brand)
    }

    static func formatBytes(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / (1024 * 1024 * 1024)
        return String(format: "%.1f GB", gb)
    }

    static func formatUptime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}
