//
//  TreflePersistentCacheManager.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/4/25.
//

import Foundation

final class TreflePersistentCacheManager {
    static let shared = TreflePersistentCacheManager()
    private init() {}

    private let fileManager = FileManager.default

    func cacheURL(for filename: String) -> URL {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(filename)
    }

    func save<T: Codable>(_ data: T, to filename: String) {
        do {
            let url = cacheURL(for: filename)
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: .atomic)
            
            // Prevent iCloud backup of cache
                  var resourceValues = URLResourceValues()
                  resourceValues.isExcludedFromBackup = true
                  var mutableURL = url
                  try mutableURL.setResourceValues(resourceValues)
            print("✅ Saved \(filename)")
        } catch {
            print("❌ Error saving \(filename): \(error.localizedDescription)")
        }
    }

    func load<T: Codable>(_ type: T.Type, from filename: String) -> T? {
        let url = cacheURL(for: filename)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("⚠️ Failed to load \(filename): \(error.localizedDescription)")
            return nil
        }
    }

    func clear(filename: String) {
        let url = cacheURL(for: filename)
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                print("🗑️ Cleared \(filename)")
            }
        } catch {
            print("❌ Failed to delete \(filename): \(error.localizedDescription)")
        }
    }

}

//download persistence
struct PlantDownloadProgress: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalPlants: Int
    let lastUpdated: Date
    let partialPlants: [TreflePlant]
    let elapsedTimeSoFar: TimeInterval?
}




