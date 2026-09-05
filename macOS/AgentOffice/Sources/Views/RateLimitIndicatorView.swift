// RateLimitIndicatorView.swift
import SwiftUI

struct RateLimitIndicatorView: View {
    let provider: LLMProvider
    let requestsRemaining: Int
    let requestsLimit: Int
    let resetTime: Date?

    private var usagePercent: Double {
        guard requestsLimit > 0 else { return 0 }
        return Double(requestsLimit - requestsRemaining) / Double(requestsLimit) * 100
    }

    private var statusColor: Color {
        if usagePercent < 50 { return .green }
        if usagePercent < 80 { return .yellow }
        return .red
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .font(.system(size: 12))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(provider.rawValue.capitalized)
                        .font(.system(size: 10, weight: .semibold))
                    Text("\(requestsRemaining)/\(requestsLimit) requests")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: Double(requestsRemaining), total: Double(requestsLimit))
                    .tint(statusColor)
                    .frame(height: 3)
            }

            if let resetTime {
                Text("Resets \(resetTime, style: .relative)")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }

    var statusIcon: String {
        if usagePercent < 50 { return "checkmark.circle.fill" }
        if usagePercent < 80 { return "exclamationmark.circle.fill" }
        return "xmark.circle.fill"
    }
}

// MARK: - Rate Limit Manager
class RateLimitManager: ObservableObject {
    static let shared = RateLimitManager()

    @Published var limits: [LLMProvider: RateLimitInfo] = [:]

    struct RateLimitInfo {
        var requestsRemaining: Int
        var requestsLimit: Int
        var resetTime: Date?
        var lastUpdated: Date
    }

    private init() {
        loadLimits()
    }

    func updateLimit(provider: LLMProvider, remaining: Int, limit: Int, resetTime: Date?) {
        limits[provider] = RateLimitInfo(
            requestsRemaining: remaining,
            requestsLimit: limit,
            resetTime: resetTime,
            lastUpdated: Date()
        )
        saveLimits()
    }

    func decrementLimit(provider: LLMProvider) {
        guard var info = limits[provider] else { return }
        info.requestsRemaining = max(0, info.requestsRemaining - 1)
        info.lastUpdated = Date()
        limits[provider] = info
        saveLimits()
    }

    func getLimitInfo(provider: LLMProvider) -> RateLimitInfo? {
        return limits[provider]
    }

    func isRateLimited(provider: LLMProvider) -> Bool {
        guard let info = limits[provider] else { return false }
        if let resetTime = info.resetTime, Date() < resetTime {
            return info.requestsRemaining <= 0
        }
        return false
    }

    func timeUntilReset(provider: LLMProvider) -> TimeInterval? {
        guard let info = limits[provider], let resetTime = info.resetTime else { return nil }
        let remaining = resetTime.timeIntervalSinceNow
        return remaining > 0 ? remaining : nil
    }

    private func saveLimits() {
        // Simplified - in production would use proper serialization
    }

    private func loadLimits() {
        // Simplified - in production would load from UserDefaults
    }
}
