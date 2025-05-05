//
//  SyncManager.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//

import Foundation
import SwiftData
import Combine
import SwiftUI

class SyncManager: ObservableObject {
    static let shared = SyncManager()

    private var cancellables = Set<AnyCancellable>()
    private var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
    }

    func startMonitoring(networkMonitor: NetworkMonitor) {
        networkMonitor.$isConnected
            .removeDuplicates()
            .sink { isConnected in
                if isConnected {
                    Task {
                        await self.syncAll()
                    }
                }
            }
            .store(in: &cancellables)
    }

    func syncAll() async {
        guard let context = context else { return }

        await syncPlants(context: context)
        await syncRecords(ofType: LocalWaterRecord.self, send: APIManager.shared.syncWaterRecord)
        await syncRecords(ofType: LocalGrowthRecord.self, send: APIManager.shared.syncGrowthRecord)
        await syncRecords(ofType: LocalHumidityRecord.self, send: APIManager.shared.syncHumidityRecord)
        await syncRecords(ofType: LocalLightRecord.self, send: APIManager.shared.syncLightRecord)
        await syncRecords(ofType: LocalSoilMoistureRecord.self, send: APIManager.shared.syncSoilMoistureRecord)
        await syncRecords(ofType: LocalTemperatureRecord.self, send: APIManager.shared.syncTemperatureRecord)
    }

    private func syncPlants(context: ModelContext) async {
        let unsynced = try? context.fetch(FetchDescriptor<LocalPlant>(predicate: #Predicate { !$0.isSynced }))
        for plant in unsynced ?? [] {
            let success = await APIManager.shared.syncPlant(plant)
            if success {
                plant.isSynced = true
                try? context.save()
            }
        }
    }

    private func syncRecords<T: PersistentModel & RecordSyncable>(
        ofType _: T.Type,
        send: @escaping (T) async -> Bool
    ) async {
        guard let context = context else { return }

        let unsynced = try? context.fetch(FetchDescriptor<T>(predicate: #Predicate { !$0.isSynced }))
        for var record in unsynced ?? [] {
            let success = await send(record)
            if success {
                record.isSynced = true
                try? context.save()
            }
        }
    }

    func syncRecordsWithConflictCheck<T: RecordSyncable & Identifiable & Equatable>(
        local: [T],
        fetchRemote: @escaping () async -> [T],
        resolve: @escaping (T) async -> Bool,
        context: ModelContext
    ) async {
        let remote = await fetchRemote()
        let conflicts = ConflictResolver.detectConflicts(local: local, remote: remote)

        if conflicts.isEmpty {
            for var item in local where !item.isSynced {
                let success = await resolve(item)
                if success {
                    item.isSynced = true
                    try? context.save()
                }
            }
        } else {
            for pair in conflicts {
                let pair: ConflictPair<T> = pair
                await MainActor.run {
                    ConflictController.shared.queue.append(.init(
                        resolveUI: {
                            AnyView(
                                ConflictResolutionView(conflict: pair) { chosen in
                                    Task {
                                        let success = await resolve(chosen)
                                        if success {
                                            await self.safelyResolveConflict(chosen: chosen, pair: pair, in: self.context!)
                                        }
                                    }
                                }
                            )
                        }
                    ))
                }

            }
        }
    }
    @MainActor
    func safelyResolveConflict<T: RecordSyncable & Identifiable & Equatable>(
        chosen: T,
        pair: ConflictPair<T>,
        in context: ModelContext
    ) {
        var chosen = chosen
        chosen.isSynced = true

        do {
            try context.save()
        } catch {
            print("❌ Failed to save context: \(error)")
        }

        if chosen.id == pair.local.id {
            if let model = pair.remote as? any PersistentModel {
                context.delete(model)
            }
        } else {
            if let model = pair.local as? any PersistentModel {
                context.delete(model)
            }
        }
    }



}//end class
