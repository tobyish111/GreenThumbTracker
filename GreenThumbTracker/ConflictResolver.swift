//
//  ConflictResolver.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//

import Foundation
//conflict resolving logic
struct ConflictPair<T: RecordSyncable> {
    let local: T
    let remote: T
}

class ConflictResolver {
    static func detectConflicts<T: RecordSyncable>(
        local: [T],
        remote: [T],
        toleranceSeconds: TimeInterval = 60
    ) -> [ConflictPair<T>] {
        var result: [ConflictPair<T>] = []

        for localRecord in local where !localRecord.isSynced {
            if let match = remote.first(where: { abs($0.date.timeIntervalSince(localRecord.date)) < toleranceSeconds }) {
                result.append(ConflictPair(local: localRecord, remote: match))
            }
        }
        return result
    }
}
//app state class
final class AppState: ObservableObject {
    @Published var isOffline: Bool = false
}

