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
