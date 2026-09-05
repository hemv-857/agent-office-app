// RetryService.swift
import Foundation
import Combine

class RetryService: ObservableObject {
    static let shared = RetryService()

    @Published var retryHistory: [RetryEntry] = []

    struct RetryEntry: Identifiable, Codable {
        let id = UUID()
        let operation: String
        let attempt: Int
        let maxAttempts: Int
        let error: String
        let delay: TimeInterval
        let timestamp: Date
        let success: Bool
    }

    struct RetryConfig {
        let maxAttempts: Int
        let baseDelay: TimeInterval
        let maxDelay: TimeInterval
        let backoffMultiplier: Double
        let jitterRange: ClosedRange<Double>

        static let `default` = RetryConfig(
            maxAttempts: 3,
            baseDelay: 1.0,
            maxDelay: 30.0,
            backoffMultiplier: 2.0,
            jitterRange: 0.8...1.2
        )
    }

    private init() {}

    func calculateDelay(attempt: Int, config: RetryConfig = .default) -> TimeInterval {
        let exponentialDelay = config.baseDelay * pow(config.backoffMultiplier, Double(attempt - 1))
        let clampedDelay = min(exponentialDelay, config.maxDelay)
        let jitter = Double.random(in: config.jitterRange)
        return clampedDelay * jitter
    }

    func shouldRetry(attempt: Int, error: Error, config: RetryConfig = .default) -> Bool {
        guard attempt < config.maxAttempts else { return false }

        // Don't retry on certain errors
        let nsError = error as NSError
        switch nsError.code {
        case 401, 403: return false  // Auth errors
        case 404: return false       // Not found
        case 422: return false       // Validation
        default: break
        }

        // Retry on rate limit, server errors, network errors
        return true
    }

    func recordRetry(operation: String, attempt: Int, maxAttempts: Int, error: String, delay: TimeInterval, success: Bool) {
        let entry = RetryEntry(
            operation: operation,
            attempt: attempt,
            maxAttempts: maxAttempts,
            error: error,
            delay: delay,
            timestamp: Date(),
            success: success
        )
        retryHistory.insert(entry, at: 0)
        if retryHistory.count > 50 {
            retryHistory = Array(retryHistory.prefix(50))
        }
    }

    func executeWithRetry<T>(
        operation: String,
        config: RetryConfig = .default,
        action: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        for attempt in 1...config.maxAttempts {
            do {
                let result = try await action()
                if attempt > 1 {
                    recordRetry(operation: operation, attempt: attempt, maxAttempts: config.maxAttempts, error: "", delay: 0, success: true)
                }
                return result
            } catch {
                lastError = error
                if !shouldRetry(attempt: attempt, error: error, config: config) {
                    recordRetry(operation: operation, attempt: attempt, maxAttempts: config.maxAttempts, error: error.localizedDescription, delay: 0, success: false)
                    throw error
                }
                let delay = calculateDelay(attempt: attempt, config: config)
                recordRetry(operation: operation, attempt: attempt, maxAttempts: config.maxAttempts, error: error.localizedDescription, delay: delay, success: false)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        throw lastError ?? NSError(domain: "RetryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Max retries exceeded"])
    }
}
