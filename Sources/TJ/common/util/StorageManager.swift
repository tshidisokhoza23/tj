import Foundation

public class StorageManager: ObservableObject {
    public static let shared = StorageManager()

    @Published public var cacheSizeMB: Double = 0.0

    public init() {
        calculateCacheSize()
    }

    public func calculateCacheSize() {
        DispatchQueue.global(qos: .utility).async {
            let fileManager = FileManager.default
            guard let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }

            var size: UInt64 = 0
            if let enumerator = fileManager.enumerator(at: cacheUrl, includingPropertiesForKeys: [.fileSizeKey]) {
                for case let fileUrl as URL in enumerator {
                    if let attributes = try? fileManager.attributesOfItem(atPath: fileUrl.path),
                       let fileSize = attributes[.size] as? UInt64 {
                        size += fileSize
                    }
                }
            }

            DispatchQueue.main.async {
                self.cacheSizeMB = Double(size) / (1024.0 * 1024.0)
            }
        }
    }

    public func formattedCacheSize() -> String {
        String(format: "%.1f MB", cacheSizeMB)
    }

    public func clearCache(_ completion: @escaping () -> Void) {
        clearAllCache()
        completion()
    }

    public func clearAllCache() {
        URLCache.shared.removeAllCachedResponses()
        let fileManager = FileManager.default
        if let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? fileManager.removeItem(at: cacheUrl)
            try? fileManager.createDirectory(at: cacheUrl, withIntermediateDirectories: true)
        }
        calculateCacheSize()
    }
}

public final class MediaCacheManager {

    public static func getTempMediaDir() -> URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = cachesDir.appendingPathComponent("media_temp", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public static func createTempFile(prefix: String = "media_", suffix: String = ".tmp") -> URL {
        let dir = getTempMediaDir()
        let filename = "\(prefix)\(UUID().uuidString)\(suffix)"
        return dir.appendingPathComponent(filename)
    }

    public static func cleanExpiredCache(maxAgeSeconds: TimeInterval = 24 * 60 * 60) {
        let dir = getTempMediaDir()
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }

        let cutoffDate = Date().addingTimeInterval(-maxAgeSeconds)
        for file in files {
            if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
               let modDate = attributes[.modificationDate] as? Date,
               modDate < cutoffDate {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}

public final class UserScopedStorage {

    private let userId: String

    public init(userId: String) {
        self.userId = userId
    }

    public func getAttachmentsDir() -> URL {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docsDir.appendingPathComponent("attachments/\(userId)", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public func getTempDir() -> URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = cachesDir.appendingPathComponent("temp/\(userId)", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public func clearUserData() {
        try? FileManager.default.removeItem(at: getAttachmentsDir())
        try? FileManager.default.removeItem(at: getTempDir())
    }
}
