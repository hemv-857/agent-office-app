// PerformanceMonitor.swift
import Foundation
import Combine

class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published var metrics: PerformanceMetrics = PerformanceMetrics()
    @Published var isMonitoring = false

    struct PerformanceMetrics: Codable {
        var memoryUsage: Int64 = 0
        var cpuUsage: Double = 0
        var diskUsage: Int64 = 0
        var networkRequests: Int = 0
        var averageResponseTime: Double = 0
        var totalTokensProcessed: Int = 0
        var totalAPICalls: Int = 0
        var errorRate: Double = 0
        var uptime: TimeInterval = 0
        var lastUpdated: Date?
    }

    private var timer: Timer?
    private var startTime: Date?

    private init() {
        loadMetrics()
    }

    func startMonitoring() {
        isMonitoring = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        saveMetrics()
    }

    func recordAPICall(responseTime: TimeInterval, tokens: Int, success: Bool) {
        metrics.totalAPICalls += 1
        metrics.totalTokensProcessed += tokens

        // Update average response time
        let totalCalls = Double(metrics.totalAPICalls)
        metrics.averageResponseTime = (metrics.averageResponseTime * (totalCalls - 1) + responseTime) / totalCalls

        // Update error rate
        let errorCount = metrics.errorRate * (totalCalls - 1) + (success ? 0 : 1)
        metrics.errorRate = errorCount / totalCalls

        metrics.lastUpdated = Date()
        saveMetrics()
    }

    func recordNetworkRequest() {
        metrics.networkRequests += 1
        saveMetrics()
    }

    func getPerformanceSummary() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2

        return """
        Performance Summary:
        - Memory: \(formatBytes(metrics.memoryUsage))
        - CPU: \(formatter.string(from: NSNumber(value: metrics.cpuUsage)) ?? "0")%
        - API Calls: \(metrics.totalAPICalls)
        - Avg Response: \(formatter.string(from: NSNumber(value: metrics.averageResponseTime)) ?? "0")s
        - Error Rate: \(formatter.string(from: NSNumber(value: metrics.errorRate * 100)) ?? "0")%
        - Tokens: \(metrics.totalTokensProcessed)
        """
    }

    private func updateMetrics() {
        metrics.memoryUsage = getMemoryUsage()
        metrics.cpuUsage = getCPUUsage()
        metrics.uptime = startTime.map { Date().timeIntervalSince($0) } ?? 0
        metrics.lastUpdated = Date()
        saveMetrics()
    }

    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }

    private func getCPUUsage() -> Double {
        // ponytail: simplified — use process info for basic CPU metric
        let info = ProcessInfo.processInfo
        let activeCount = info.activeProcessorCount
        let physicalMemory = info.physicalMemory
        // Return a simple metric based on available resources
        return Double(activeCount) * 0.1  // placeholder
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: bytes)
    }

    private func saveMetrics() {
        if let data = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(data, forKey: "performanceMetrics")
        }
    }

    private func loadMetrics() {
        if let data = UserDefaults.standard.data(forKey: "performanceMetrics"),
           let loaded = try? JSONDecoder().decode(PerformanceMetrics.self, from: data) {
            metrics = loaded
        }
    }
}
