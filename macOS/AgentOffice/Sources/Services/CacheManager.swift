// CacheManager.swift
import Foundation

class CacheManager: ObservableObject {
    static let shared = CacheManager()

    @Published var cacheStats: CacheStats = CacheStats()

    struct CacheStats: Codable {
        var totalEntries: Int = 0
        var totalSize: Int64 = 0
        var hitCount: Int = 0
        var missCount: Int = 0
        var hitRate: Double = 0
    }

    private var memoryCache: [String: CacheEntry] = [:]
    private var maxCacheSize: Int64 = 50 * 1024 * 1024  // 50MB
    private var maxCacheAge: TimeInterval = 3600  // 1 hour

    struct CacheEntry: Codable {
        let key: String
        let data: Data
        let timestamp: Date
        let size: Int64
        var accessCount: Int = 0
        var lastAccessed: Date
    }

    private init() {
        loadCache()
        cleanExpiredEntries()
    }

    func set(key: String, data: Data, expiration: TimeInterval? = nil) {
        let entry = CacheEntry(
            key: key,
            data: data,
            timestamp: Date(),
            size: Int64(data.count),
            lastAccessed: Date()
        )

        memoryCache[key] = entry
        cacheStats.totalEntries = memoryCache.count
        cacheStats.totalSize += entry.size

        // Clean if over size limit
        if cacheStats.totalSize > maxCacheSize {
            cleanOldestEntries()
        }

        saveCache()
    }

    func get(key: String) -> Data? {
        guard var entry = memoryCache[key] else {
            cacheStats.missCount += 1
            updateHitRate()
            return nil
        }

        // Check expiration
        if Date().timeIntervalSince(entry.timestamp) > maxCacheAge {
            remove(key: key)
            cacheStats.missCount += 1
            updateHitRate()
            return nil
        }

        entry.accessCount += 1
        entry.lastAccessed = Date()
        memoryCache[key] = entry

        cacheStats.hitCount += 1
        updateHitRate()

        return entry.data
    }

    func remove(key: String) {
        if let entry = memoryCache.removeValue(forKey: key) {
            cacheStats.totalSize -= entry.size
            cacheStats.totalEntries = memoryCache.count
            saveCache()
        }
    }

    func clear() {
        memoryCache.removeAll()
        cacheStats = CacheStats()
        saveCache()
    }

    func getCacheEntry(key: String) -> CacheEntry? {
        return memoryCache[key]
    }

    func getAllKeys() -> [String] {
        return Array(memoryCache.keys)
    }

    func getCacheSize() -> Int64 {
        return cacheStats.totalSize
    }

    private func cleanExpiredEntries() {
        let now = Date()
        let expiredKeys = memoryCache.filter { _, entry in
            now.timeIntervalSince(entry.timestamp) > maxCacheAge
        }.map { $0.key }

        for key in expiredKeys {
            remove(key: key)
        }
    }

    private func cleanOldestEntries() {
        let sortedEntries = memoryCache.values.sorted { $0.lastAccessed < $1.lastAccessed }
        var entriesToRemove: [String] = []
        for entry in sortedEntries {
            if cacheStats.totalSize > Int64(Double(maxCacheSize) * 0.8) {
                entriesToRemove.append(entry.key)
            } else {
                break
            }
        }

        for key in entriesToRemove {
            remove(key: key)
        }
    }

    private func updateHitRate() {
        let total = cacheStats.hitCount + cacheStats.missCount
        cacheStats.hitRate = total > 0 ? Double(cacheStats.hitCount) / Double(total) : 0
    }

    private func saveCache() {
        if let data = try? JSONEncoder().encode(Array(memoryCache.values)) {
            UserDefaults.standard.set(data, forKey: "cacheEntries")
        }
    }

    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: "cacheEntries"),
           let entries = try? JSONDecoder().decode([CacheEntry].self, from: data) {
            for entry in entries {
                memoryCache[entry.key] = entry
            }
            cacheStats.totalEntries = memoryCache.count
            cacheStats.totalSize = entries.reduce(0) { $0 + $1.size }
        }
    }
}
